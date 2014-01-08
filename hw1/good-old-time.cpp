/*
 * =====================================================================================
 *
 *       Filename:  good-old-time.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  01/06/2014 21:58:24
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Jianfeng Jia (), jianfeng.jia@gmail.com
 *   Organization:  
 *
 * =====================================================================================
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

typedef char BYTE;

FILE* create_secondary_memory(const char* filename){
    return fopen(filename, "wb+");
}

// byte is enough for 255 fields
BYTE & get_fields_count(BYTE * data){
    return data[0];
}

// short is enough for 1024 memory
short & get_field_offset(BYTE * data, int id){
    return *((short*)(data+1) + id );
}

void set_field_length(BYTE * data, int id, short length){
    get_field_offset(data, id+1) = get_field_offset(data, id) +  length;
}

int get_header_size(BYTE * data){
    return 1 + data[0] * sizeof(short);
}

BYTE* get_field_data(BYTE * data, int id){
    return data + get_header_size(data) + get_field_offset(data,id) ;
}

void initial_for_process(BYTE data[], int size_data, int count_fields, const char* stopwords_filename){
    get_fields_count(data) =  count_fields;

    FILE* file = fopen(stopwords_filename, "r");
    fgets(get_field_data(data,0) , size_data, file);
    fclose(file);

    // data[0]: the stopword list
    set_field_length(data, 0, (short)( strnlen((char*) data, size_data)));     
    // data[1]: the readline, fix 80
    set_field_length(data, 1, 80);
    // data[2]: the pointer of current char, 255 is enough for 80 chars.
    set_field_length(data, 2, 1);
    // data[3]: the start pos of the word, 255 is enough;
    set_field_length(data, 3, 1);
    // data[4]: the word in secondary_memory, assume the longgest word is length 32
    set_field_length(data, 4, 32);
    // data[5]: the word frequency
    set_field_length(data, 5, sizeof(int));
    // data[6]: if already exists
    set_field_length(data, 6, 1);
}

bool & get_finish_flag(BYTE* data){
    return *((bool*) get_field_data( data, get_idx_finish_flag()));
}

int & get_offset_current_char(BYTE* data){
    return *((int*) get_field_data( data, get_idx_int_offset_current_char()));
}

char & get_current_char(BYTE* data){
    return *((char*) get_field_data( data, get_offset_current_char(data)));
}

void move_forward(BYTE* data){
    get_offset_current_char(data) += 1;
}

char * get_line_cache(BYTE* data){
    return get_field_data(data, get_idx_line_cache() );
}

char* get_current_word(BYTE* data){
    return get_line_cache(data) + get_start_offset(data);
}

char* get_stop_words(BYTE* data){
    return get_field_data(data, get_idx_stop_word());
}

bool match ( char* word, char* stop_words){
    return strstr(stop_words, word) != NULL;
}

/// Update the cur_word into secondary_memory;
void update( BYTE* data, FILE* secondary_memory){
    fseek(secondary_memory, 0, SEEK_SET);
    while(fread( get_2nd_word(data), 1 , 20, secondary_memory) > 0){
        fread( get_2nd_freq(data), sizeof(int), 1, secondary_memory);
        if ( strcmp( get_current_word(data), get_2nd_word(data)) != 0){
            fseek( secondary_memory, -sizeof(int), SEEK_CUR);
            * (int*) get_2nd_freq(data) += 1;
            fwrite( get_2nd_freq(data), sizeof(int), 1, secondary_memory);
            return ;
        }
    }
    // didn't find it
    fwrite( get_current_word(data), 1, 20, secondary_memory);
    * (int*)get_2nd_freq(data) = 1;
    fwrite( get_2nd_freq(data), sizeof(int), 1, secondary_memory);
}

/// Read the input file and process the word into secondary_memory 
void process_input(const char* filename, BYTE* data, FILE* secondary_memory){
    FILE * fp = fopen(filename, "r");
    // get line to data[1]
    while (fgets(get_line_cache(data) , 80, fp)){
        get_finish_flag(data) =  false;
        get_start_offset(data) = 0;
        while ( !get_finish_flag(data)){
            if (isalnum( get_current_char( data))){
                get_current_char(data) = tolower(get_current_char(data));
                move_forward(data);
                continue;
            }
            if ( 0 == get_current_char( data)){
                get_finish_flag(data) = true;
            }
            // find a word 
            get_current_char(data) =  0;
            if ( strnlen(get_current_word(data), 20) > 1 && !match(get_current_word(data), get_stop_words(data)) ){
                update( data, secondary_memory);
            }
            get_start_offset(data) =  get_offset_current_char() + 1; // point to the next char
            move_forward(data);
        }
    }
    fclose(fp);
}

void output_freq(BYTE* data, FILE * secondary_memory){
    fflush(secondary_memory);
    fseek( secondary_memory, 0, SEEK_SET);
    while(fread( get_final_word(data), 1 , 20, secondary_memory) > 0){
        fread( get_final_freq(data), sizeof(int), 1, secondary_memory);
 
        while ( get_output_loop_counter(data) < 25){
            if ( get_topk_freq(data, get_output_loop_counter(data)) < get_cur_dict_freq(data)){
                insert( data, get_cur_dict_word(data), get_cur_dict_freq(data));
            }
            get_output_loop_counter(data) +=1;
        }
    }
}

int main(int argc, char** argv){
    BYTE data[1024] = {0};

    FILE* secondary_memory = create_secondary_memory("word_freqs");

    initial_for_process(data, 1024, "../stop_words.txt");
    
    process_input(argv[1], data);

    initial_for_output(data);

    output_freq(data, secondary_memory);

    fclose(secondary_memory);
}

/*
 * =====================================================================================
 *
 *       Filename:  good-old-time.cpp
 *
 *    Description:  This the program for the INF 212 Good old time
 *                  This program is constrained to not use the variable and also 
 *                  should work correctly under memory limit situation.
 *
 *                  The data[1024] is treated as a main memory. 
 *                  I borrowed the record idea in database to split this data[]
 *                  It contains a header, which is the metadata showing how many 
 *                  fields inside this record, and what is the offset of each fields.
 *                  
 *                  data = [header][ fields data]
 *                  header = [count of fields][#0 offset][#1 offset][#2 offset] ....
 *                  fields data = [ void * .... ] 
 *
 *                  In this way we can create as many variable as possible and don't
 *                  need to pay much more attention about their types. 
 *
 *                  I create a bunch of method to get the conresponding fields data,
 *                  like get_word_freq(data) would check the # of the word_freq field,
 *                  and return the &(void*) of the offset inside data[]
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
#include "good-old-time.h"

void initial_for_process(BYTE* data, int size_data,  const char* stopwords_filename){
    get_fields_count(data) =  get_process_field_count();

    FILE* file = fopen(stopwords_filename, "r");
    fgets(get_field_data(data, get_idx_stop_word()) , size_data, file);
    fclose(file);

    // data[0]: the stopword list
    set_field_length(data, get_idx_stop_word(), (short)( strlen( get_stop_words(data))));     
    // data[1]: the readline, fix 80
    set_field_length(data, get_idx_line_cache(), 80);
    // data[2]: the pointer of current char .
    set_field_length(data, get_idx_int_offset_current_char(), 4);
    // data[3]: the start pos of the word, 255 is enough;
    set_field_length(data, get_idx_start_offset(), 1);
    // data[4]: the flag to show if the stream is over; 
    set_field_length(data, get_idx_finish_flag(), 1);
    // data[5]: cached word to insert
    set_field_length(data, get_idx_2nd_word(), 21);
    // data[5]: cached freq to insert
    set_field_length(data, get_idx_2nd_freq(), 4);

}

/// Update the cur_word into secondary_memory;
void update( BYTE* data, FILE* secondary_memory){
    fseek(secondary_memory, 0, SEEK_SET);
    while(fread( get_2nd_word(data), 1 , 20, secondary_memory) > 0){
        fread( &get_2nd_freq(data), sizeof(int), 1, secondary_memory);
        //printf("curword: %s read2nd:%s,%d\n", get_current_word(data),
        //        get_2nd_word(data), get_2nd_freq(data));
        if ( strcmp( get_current_word(data), get_2nd_word(data)) == 0){
        //    printf("found it\n");
            fseek( secondary_memory, -sizeof(int), SEEK_CUR);
            get_2nd_freq(data) += 1;
            fwrite( &get_2nd_freq(data), sizeof(int), 1, secondary_memory);
            return ;
        }
    }
    // new word
    fwrite( get_current_word(data), 1, 20, secondary_memory);
    get_2nd_freq(data) = 1;
    fwrite( &get_2nd_freq(data), sizeof(int), 1, secondary_memory);
    //printf("newword:%s, %d\n", get_current_word(data), get_2nd_freq(data));
}

/// Read the input file and process the word into secondary_memory 
void process_input_file(const char* filename, BYTE* data, FILE* secondary_memory){
    FILE * fp = fopen(filename, "r");
    // get line to data[1]
    while (fgets(get_line_cache(data) , 80, fp)){
        get_finish_flag(data) =  false;
        get_start_offset(data) = 0;
        get_offset_current_char(data) = 0;

        //printf("line: %s\n", get_line_cache(data));
        while ( !get_finish_flag(data)){
//            printf("startoff:%d cur offset:%d, char: %c\n", 
//                    get_start_offset(data), get_offset_current_char(data),
//                    get_current_char(data));
            if (isalnum( get_current_char( data))){
                get_current_char(data) =(char) tolower(get_current_char(data));
                move_forward(data);
                continue;
            }
            if ( 0 == get_current_char( data)){
                get_finish_flag(data) = true;
            }
            // find a word 
            get_current_char(data) =  0;
            if ( get_word_length(data) > 1 
                    && !match(get_current_word(data), get_stop_words(data)) ){
                //printf("update: %s\n", get_current_word(data));
                update( data, secondary_memory);
            }
            get_start_offset(data) =  get_offset_current_char(data) + 1; // point to the next char
            move_forward(data);
        }
    }
    fclose(fp);
}

void initial_for_output(BYTE *data){
    memset(data, 0, 1024);
    get_fields_count(data) = get_output_field_count();
    
    // each word is at most 20 chars + 1 for '\0'
    set_field_length(data, get_idx_final_word(), 21);
    // the freq 
    set_field_length(data, get_idx_final_freq(), 4);
    // the base location to store all the pairs
    set_field_length(data, get_idx_final_base_kth(), 25 * (21+4));
    // the space to store the internal loop "i"
    set_field_length(data, get_idx_final_output_loop_counter(), 4);
    // another inner loop integer
    set_field_length(data, get_idx_insert_loop_count(), 4);
}

void insert(BYTE* data, int idx, char* word, int freq){
    // shift the data from idx to 25 by size of one pair.
    for( get_insert_loop_count(data) = 24; get_insert_loop_count(data) > idx; 
            get_insert_loop_count(data) -=1){
        memmove( get_kth_pair(data, get_insert_loop_count(data) ),
                 get_kth_pair(data, get_insert_loop_count(data)-1) , 20 + 4);
    }
    memmove( get_kth_word(data, idx), word, 20);
    memmove( &get_kth_freq(data, idx), &freq, 4);
}

void find_topk_freq(BYTE* data, FILE * secondary_memory){
    fflush(secondary_memory);
    fseek( secondary_memory, 0, SEEK_SET);
    while(fread( get_final_word(data), 1 , 20, secondary_memory) > 0){
        fread( &get_final_freq(data), sizeof(int), 1, secondary_memory);
        //printf("topk:%s, %d\n", get_final_word(data), get_final_freq(data));

        for (get_output_loop_counter(data) = 0; get_output_loop_counter(data) < 25; 
                get_output_loop_counter(data) +=1){

            //printf("topk, kthfreq: %d, final freq:%d\n",
            //      get_kth_freq(data, get_output_loop_counter(data)),
            //      get_final_freq(data));
            if ( get_kth_freq(data, get_output_loop_counter(data)) < get_final_freq(data)){
                insert( data, get_output_loop_counter(data),  get_final_word(data), get_final_freq(data));
                break;
            }
        }
    }

    for( get_output_loop_counter(data) = 0; get_output_loop_counter(data) < 25; 
            get_output_loop_counter(data) += 1){
        if ( true || strlen(get_kth_word(data, get_output_loop_counter(data))) == 2){
            printf( "%s - %d\n", get_kth_word(data, get_output_loop_counter(data)),
                    get_kth_freq(data, get_output_loop_counter(data)));
        }
    }
}

int main(int argc, char** argv){
    if (argc < 2){
        printf("usage: %s <input_file>" , argv[0]);
        return 0;
    }

    // this is the ONLY variable name used in the following methods
    BYTE data[1024] = {0};

    FILE* secondary_memory = create_secondary_memory("word_freqs");

    initial_for_process(data, 1024, "../stop_words.txt");
    
    process_input_file(argv[1], data, secondary_memory);

    initial_for_output(data);

    find_topk_freq(data, secondary_memory);

    fclose(secondary_memory);
}

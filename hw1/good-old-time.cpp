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

typedef char BYTE;

FILE* create_secondary_memory(const char* filename){
    return fopen(filename, "rb+");
}

// byte is enough for 255 fields
BYTE get_fields_count(BYTE * data){
    return data[0];
}

void set_fields_count(BYTE * data, BYTE count){
    data[0] = count;
}

// short is enough for 1024 memory
short get_field_offset(BYTE * data, int id){
    return *((short*)(data+1) + id );
}

void set_field_length(BYTE * data, int id, short length){
    *((short*)(data+1) + id +1) = get_field_offset(data, id) +  length;
}

int get_header_size(BYTE * data){
    return 1 + data[0] * sizeof(short);
}

BYTE* get_field_data(BYTE * data, int id){
    return data + get_header_size(data) + get_field_offset(data,id) ;
}

void initial(BYTE data[], int size_data, int count_fields, const char* stopwords_filename){
    set_fields_count(data, count_fields);

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

void process_input(const char* filename, BYTE data[], FILE* secondary_memory){
    FILE * fp = fopen(filename, "r");
    while (fgets( get_field_data(data, 1), 80, fp)){
       //TODO 
    }
    
    fclose(fp);
}

int main(int argc, char** argv){
    BYTE data[1024] = {0};

    FILE* secondary_memory = create_secondary_memory("word_freqs");

    initial(data, 1024, "../stop_words.txt");
    
    process_input(argv[1], data);

    output_freq(data, secondary_memory);

    fclose(secondary_memory);
}

/*
 * =====================================================================================
 *
 *       Filename:  good-old-time.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  01/08/2014 02:40:31 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *   Organization:  
 *
 * =====================================================================================
 */
#ifndef __GOOG_OLD_TIME__
#define __GOOG_OLD_TIME__
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

typedef char BYTE;

FILE* create_secondary_memory(const char* filename){
    return fopen(filename, "wb+");
}

/// The field idx arrangement for process_file method
int get_process_field_count(){
    return 6;
}

int get_idx_stop_word(){
    return 0;
}

int get_idx_line_cache(){
    return 1;
}

int get_idx_int_offset_current_char(){
    return 2;
}

int get_idx_start_offset(){
    return 3;
}

int get_idx_finish_flag(){
    return 4;
}

/// The field idx arrangement for output_final freq method
int get_output_field_count(){
    return ;
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

BYTE* get_start_offset(BYTE* data){
    return *( (BYTE*) get_field_data(data, get_idx_start_offset()));
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

char* get_final_word(BYTE* data){
    return get_field_data(data, get_idx_final_word());
}

int & get_final_freq(BYTE* data){
    return *((int*) get_field_data(data, get_idx_final_freq()));
}

int & get_output_loop_counter(BYTE* data){
    return *((int*) get_field_data(data, get_idx_final_output_loop_counter()));
}

char* get_base_kth(BYTE* data){
    return get_field_data(data, get_idx_final_base_kth());
}

char* get_kth_pair(BYTE* data, int k ){
    return get_base_kth(data) + k * 24; // 20 char + 4 byte int
}

char* get_kth_word(BYTE* data, int k){
    retur get_kth_pair(data, k);
}

int & get_kth_freq( BYTE* data, int k ){
    return *((int*) (get_kth_pair() + 20));
}

#endif

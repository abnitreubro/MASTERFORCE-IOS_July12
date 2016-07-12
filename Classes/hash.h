/*file_name: VID_20XXXXXXXX_XXXXXX.AVI*/
unsigned int ap_storage_rec_name_to_hash(char *file_name);
//3、
//根据hash获取文件名
void ap_storage_hash_to_rec_name(char *buf,unsigned int hash);
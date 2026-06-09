#include <sqlite3.h>
#include <string.h>

sqlite3 *db = NULL;
sqlite3_stmt *stmt = NULL;

int db_open(const char *path) {
    return sqlite3_open(path, &db);
}

int db_prepare(const char *sql) {
    return sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
}

int db_step(void) {
    return sqlite3_step(stmt);
}

void db_col_int64(int col, long long *val) {
    *val = sqlite3_column_int64(stmt, col);
}

void db_col_str40(int col, char *buf) {
    const char *s = (const char*)sqlite3_column_text(stmt, col);
    strncpy(buf, s ? s : "", 40);
}

// ... implémente toutes les fonctions appelées dans ton COBOL
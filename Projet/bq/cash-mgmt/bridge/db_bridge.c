/***********************************************************
 * db_bridge.c - Pont C/SQLite pour COBOL
 * Branch Cash Management System
 * Expose des fonctions C appelables depuis GnuCOBOL
 ***********************************************************/
#include <sqlite3.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static sqlite3      *db_handle = NULL;
static sqlite3_stmt *stmt      = NULL;

/* Utilitaire: copie chaine COBOL (espaces trailing) -> C string */
static void cobol_to_c(const char *src, int src_len, char *dst, int dst_size) {
    int len = src_len < dst_size - 1 ? src_len : dst_size - 1;
    while (len > 0 && src[len-1] == ' ') len--;
    strncpy(dst, src, len);
    dst[len] = '\0';
}

/* Utilitaire: copie C string -> champ COBOL (padde avec espaces) */
static void c_to_cobol(const char *src, char *dst, int dst_len) {
    int slen = src ? (int)strlen(src) : 0;
    if (slen > dst_len) slen = dst_len;
    memset(dst, ' ', dst_len);
    if (slen > 0) memcpy(dst, src, slen);
}

/*----------------------------------------------------------
 * db_open(path CHAR(200)) RETURNING INT
 * Ouvre / crée la base SQLite
 *----------------------------------------------------------*/
int db_open(char *path) {
    char buf[256];
    cobol_to_c(path, 200, buf, sizeof(buf));
    int rc = sqlite3_open(buf, &db_handle);
    return rc;  /* 0 = SQLITE_OK */
}

/*----------------------------------------------------------
 * db_exec(sql CHAR(2000)) RETURNING INT
 * Exécute du SQL sans résultat (INSERT/UPDATE/DELETE/CREATE)
 *----------------------------------------------------------*/
int db_exec(char *sql) {
    char buf[2000];
    cobol_to_c(sql, 2000, buf, sizeof(buf));
    char *errmsg = NULL;
    int rc = sqlite3_exec(db_handle, buf, NULL, NULL, &errmsg);
    if (errmsg) sqlite3_free(errmsg);
    return rc;
}

/*----------------------------------------------------------
 * db_prepare(sql CHAR(2000)) RETURNING INT
 * Prépare un SELECT
 *----------------------------------------------------------*/
int db_prepare(char *sql) {
    char buf[2000];
    cobol_to_c(sql, 2000, buf, sizeof(buf));
    if (stmt) { sqlite3_finalize(stmt); stmt = NULL; }
    return sqlite3_prepare_v2(db_handle, buf, -1, &stmt, NULL);
}

/*----------------------------------------------------------
 * db_step() RETURNING INT
 * Avance d'une ligne: 100=SQLITE_ROW, 101=SQLITE_DONE
 *----------------------------------------------------------*/
int db_step(void) {
    return sqlite3_step(stmt);
}

/*----------------------------------------------------------
 * db_col_text(col INT, out CHAR(100)) - col 0-based
 * Lit une colonne texte dans un champ COBOL
 *----------------------------------------------------------*/
void db_col_text(int *col, char *out) {
    const char *val = (const char*)sqlite3_column_text(stmt, *col);
    c_to_cobol(val, out, 100);
}

/*----------------------------------------------------------
 * db_col_str40(col INT, out CHAR(40))
 *----------------------------------------------------------*/
void db_col_str40(int *col, char *out) {
    const char *val = (const char*)sqlite3_column_text(stmt, *col);
    c_to_cobol(val ? val : "", out, 40);
}

/*----------------------------------------------------------
 * db_col_str12(col INT, out CHAR(12))
 *----------------------------------------------------------*/
void db_col_str12(int *col, char *out) {
    const char *val = (const char*)sqlite3_column_text(stmt, *col);
    c_to_cobol(val ? val : "", out, 12);
}

/*----------------------------------------------------------
 * db_col_str10(col INT, out CHAR(10))
 *----------------------------------------------------------*/
void db_col_str10(int *col, char *out) {
    const char *val = (const char*)sqlite3_column_text(stmt, *col);
    c_to_cobol(val ? val : "", out, 10);
}

/*----------------------------------------------------------
 * db_col_int64(col INT, out PIC S9(18) COMP-5)
 * Lit une colonne entière (stockée *100 pour 2 décimales)
 *----------------------------------------------------------*/
void db_col_int64(int *col, long long *out) {
    *out = sqlite3_column_int64(stmt, *col);
}

/*----------------------------------------------------------
 * db_finalize() - Libère le statement préparé
 *----------------------------------------------------------*/
int db_finalize(void) {
    if (stmt) { sqlite3_finalize(stmt); stmt = NULL; }
    return 0;
}

/*----------------------------------------------------------
 * db_close() - Ferme la base
 *----------------------------------------------------------*/
int db_close(void) {
    if (stmt) { sqlite3_finalize(stmt); stmt = NULL; }
    if (db_handle) { sqlite3_close(db_handle); db_handle = NULL; }
    return 0;
}

/*----------------------------------------------------------
 * db_last_rowid(out PIC S9(18) COMP-5)
 *----------------------------------------------------------*/
void db_last_rowid(long long *out) {
    *out = sqlite3_last_insert_rowid(db_handle);
}

/*----------------------------------------------------------
 * db_changes(out PIC S9(9) COMP-5)
 * Nombre de lignes affectées par dernier INSERT/UPDATE/DELETE
 *----------------------------------------------------------*/
void db_changes(int *out) {
    *out = sqlite3_changes(db_handle);
}

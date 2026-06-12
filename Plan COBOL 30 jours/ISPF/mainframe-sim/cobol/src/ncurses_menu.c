#include <ncurses.h>

void init_screen()
{
    initscr();
    start_color();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);

    init_pair(1, COLOR_CYAN, COLOR_BLACK);
    init_pair(2, COLOR_YELLOW, COLOR_BLACK);
    init_pair(3, COLOR_GREEN, COLOR_BLACK);
}

void draw_menu()
{
    clear();

    attron(COLOR_PAIR(1) | A_BOLD);

    mvprintw(1,15,"####################################################");
    mvprintw(2,20,"IBM MAINFRAME SIMULATOR COBOL V1.0");
    mvprintw(3,15,"####################################################");

    attroff(COLOR_PAIR(1) | A_BOLD);

    attron(COLOR_PAIR(2));

    mvprintw(5,10,"===== DEVELOPPEMENT =====");

    mvprintw(7,10,"1  - Edit COBOL Source");
    mvprintw(8,10,"2  - Compile Program");
    mvprintw(9,10,"3  - Run Program");
    mvprintw(10,10,"4  - List Sources");

    mvprintw(12,10,"===== SYSTEME =====");

    mvprintw(13,10,"5  - System Status");
    mvprintw(14,10,"6  - Memory Usage");
    mvprintw(15,10,"7  - Disk Usage");
    mvprintw(16,10,"8  - View Logs");

    mvprintw(18,10,"===== OUTILS =====");

    mvprintw(19,10,"9  - Help");
    mvprintw(20,10,"10 - Date System");
    mvprintw(21,10,"11 - Process List");
    mvprintw(22,10,"12 - Database Status");

    mvprintw(24,10,"===== ADMIN =====");

    mvprintw(25,10,"13 - Backup");
    mvprintw(26,10,"14 - Configuration");
    mvprintw(27,10,"15 - About");

    mvprintw(29,10,"0  - Exit");

    attroff(COLOR_PAIR(2));

    attron(COLOR_PAIR(3));
    mvprintw(31,10,"Choice : ");
    attroff(COLOR_PAIR(3));

    refresh();
}

void wait_key()
{
    getch();
}

void close_screen()
{
    endwin();
}
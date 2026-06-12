#include <ncurses.h>

void init_screen()
{
    initscr();
    cbreak();
    noecho();
}

void close_screen()
{
    endwin();
}

void print_title()
{
    mvprintw(2,20,"IBM MAINFRAME SIMULATOR");
    refresh();
}

void wait_key()
{
    getch();
}
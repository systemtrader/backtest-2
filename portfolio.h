#define PORTFOLIO_SIZE_MAX 200
typedef enum action {
    buy,
    sell,
    nothing
} Action;

typedef struct security {
    char * symbol;
    double price;
    int shares;
    Action action;
} Security;

typedef struct portfolio {
    int size;
    Security * securities;
} Portfolio;

double marketvalue (struct portfolio * port);
 

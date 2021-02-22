#include <stdint.h>
extern int lab7(void);
extern uint32_t random_number(void);

int main()
{
    lab7();
}
uint32_t randomizor(uint32_t x);
uint32_t calcPeriod(uint32_t level);
uint32_t dterFlyLoc(uint32_t num);
uint32_t getScore(uint32_t timeLeft);
uint32_t getTime(uint32_t level);

uint32_t randomizor(uint32_t x){
    uint32_t rand = 0;
    uint32_t i = 0;
    while(i < 4){
        x = x * x;
        rand = (rand << 8) | ((x & 0x0FF0) >> 4);
        i++;
    }
    x = x % 100;
    return x;
}

uint32_t calcPeriod(uint32_t level){
    float speed = 1 - (level * (.05));
    if(speed < .1){
        speed = .1;
    }
    speed = speed * 8000000;
    return speed;
}

uint32_t dterFlyLoc(uint32_t num){
    int x = 0;
   if(num >= 30){
       x = (num % 2);
   }else{
       x = (num % 2) + 2;
   }
   x = x * 10;
   return x;

}

uint32_t getScore(uint32_t timeLeft){
    int score = timeLeft * 10;
    return score;
}

uint32_t getTime(uint32_t level){
    return 60 - (level * 10);
}


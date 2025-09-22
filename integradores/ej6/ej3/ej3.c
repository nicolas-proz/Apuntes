#include "../ejs.h"

uint64_t cant_tweets(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)){
    uint64_t res = 0;
    feed_t* feed = user->feed;
    publicacion_t *actual = feed->first;
    uint32_t id = user->id;
    while (actual)
    {
        tuit_t *tweet = actual->value;
        uint32_t id_tweet = tweet->id_autor;
        if (id == id_tweet)
        {
            uint8_t check = esTuitSobresaliente(tweet);
            if (check == 1)
            {
                res++;
            } 
        }
        actual = actual->next; 
    }
    return res;
    
}
tuit_t **trendingTopic(usuario_t *user,
                       uint8_t (*esTuitSobresaliente)(tuit_t *)) {
    int cant_trend = cant_tweets(user, esTuitSobresaliente);
    if (cant_trend == 0)
    {
        return NULL;
    }
    tuit_t **trending = malloc(sizeof(tuit_t*)*(cant_trend+1));
    int indice = 0;

    feed_t* feed = user->feed;
    publicacion_t *actual = feed->first;
    uint32_t id = user->id;
    while (actual)
    {
        tuit_t *tweet = actual->value;
        uint32_t id_tweet = tweet->id_autor;
        if (id == id_tweet)
        {
            uint8_t check = esTuitSobresaliente(tweet);
            if (check == 1)
            {
                trending[indice] = tweet;
                indice++;
            } 
        }
        actual = actual->next;
    }
    trending[indice] = NULL;
    
    return trending;
}

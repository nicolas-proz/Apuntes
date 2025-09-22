#include "../ejs.h"
#include <string.h>

void agregar(feed_t *feed, tuit_t *t){
  publicacion_t *nueva = malloc(sizeof(publicacion_t));
  nueva->value = t;
  nueva->next = feed->first;
  feed->first = nueva;
}
// Función principal: publicar un tuit
tuit_t *publicar(char *mensaje, usuario_t *user) {
    tuit_t *tweet = malloc(sizeof(tuit_t));
    tweet->favoritos = 0;
    tweet->retuits = 0;
    uint32_t autor = user->id;
    tweet->id_autor = autor;
    strcpy(tweet->mensaje, mensaje);

    agregar(user->feed, tweet);

    uint32_t seguidores = user->cantSeguidores;
    for (uint32_t i = 0; i < seguidores; i++)
    {
      feed_t *feed_seguidor = user->seguidores[i]->feed;
      agregar(feed_seguidor, tweet);
    }
    return tweet;
}

#include "../ejs.h"

void borrar(feed_t* feed, usuario_t *usuario_a_bloquear){
  uint32_t id_bloq = usuario_a_bloquear->id;
  publicacion_t *actual = feed->first;
  publicacion_t *anterior = NULL;
  while (actual)
  {
    tuit_t *tweet = actual->value;
    uint32_t id = tweet->id_autor;
    if (id == id_bloq)
    {
      if (anterior)
      {
          publicacion_t *tmp = actual;
          anterior->next = actual->next;
          actual = actual->next;
          free(tmp);
      }
      else
      {
        publicacion_t *tmp = actual;
        feed->first = actual->next;
        actual = actual->next;
        free(tmp);
       
      }
    }
    else
    {
      anterior = actual;
      actual = actual->next;
    }
  }
}

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear){
  feed_t *feed_usuario = usuario->feed;
  borrar(feed_usuario, usuarioABloquear);

  uint32_t cant = usuario->cantBloqueados;
  usuario->bloqueados[cant] = usuarioABloquear;
  usuario->cantBloqueados++;
  
  feed_t *feed_bloqueado = usuarioABloquear->feed;
  borrar(feed_bloqueado, usuario);
  return;
}

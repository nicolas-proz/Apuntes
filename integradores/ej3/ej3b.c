#include "../ejs.h"

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){
    int indice = 0;
    for (int i = 0; i < largo; i++)
    {
        caso_t *actual = &arreglo_casos[i];
        usuario_t *usuario = actual->usuario;
        uint32_t nivel = usuario->nivel;

        if (nivel == 1 || nivel == 2)
        {
            uint16_t caso = funcion(actual);
            if (caso == 1)
            {
                actual->estado = 1;
            }
            else if (caso == 0 && (strncmp(actual->categoria, "CLT", 4) == 0 || strncmp(actual->categoria, "RBO", 4) == 0))
            {
                actual->estado = 2;
            }
            else
            {
                casos_a_revisar[indice] = *actual;
                indice++;
            }
        } 
        else
        {
            casos_a_revisar[indice] = *actual;
            indice++;
        } 
    }
}


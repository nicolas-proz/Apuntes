#include "../ejs.h"

// Función auxiliar para contar casos por nivel
caso_t *contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel) {
    int cantidad = 0;
    for (int i = 0; i < largo; i++)
    {
        caso_t actual = arreglo_casos[i];
        usuario_t *usuario = actual.usuario;
        uint32_t nivel_actual = usuario->nivel;
        if (nivel_actual == nivel)
        {
            cantidad++;
        }
    }
    caso_t *res = cantidad > 0 ? malloc(sizeof(caso_t)*cantidad) : NULL;
    return res;
    
}

segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {
    caso_t *cero = contar_casos_por_nivel(arreglo_casos, largo, 0);
    caso_t *uno = contar_casos_por_nivel(arreglo_casos, largo, 1);
    caso_t *dos = contar_casos_por_nivel(arreglo_casos, largo, 2);

    segmentacion_t *solucion = malloc(sizeof(segmentacion_t));

    int c = 0, u = 0, d = 0;

    for (int i = 0; i < largo; i++)
    {
        usuario_t *actual = arreglo_casos[i].usuario;
        uint32_t nivel_actual = actual->nivel;
        if (nivel_actual == 0)
        {
            cero[c] = arreglo_casos[i];
            c++;
        } else if (nivel_actual == 1)
        {
            uno[u] = arreglo_casos[i];
            u++;
        } else
        {
            dos[d] = arreglo_casos[i];
            d++;
        }  
    }
    solucion->casos_nivel_0 = cero;
    solucion->casos_nivel_1 = uno;
    solucion->casos_nivel_2 = dos;

    return solucion;
}





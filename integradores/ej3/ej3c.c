#include "../ejs.h"

void actualizar_estadisticas(estadisticas_t *solucion, caso_t *actual){
    if (strncmp(actual->categoria, "CLT", 4) == 0)
    {   
        solucion->cantidad_CLT ++;
    }
    if (strncmp(actual->categoria, "RBO", 4) == 0)
    {
        solucion->cantidad_RBO ++;
    }
    if (strncmp(actual->categoria, "KSC", 4) == 0)
    {
        solucion->cantidad_KSC ++;
    }
    if (strncmp(actual->categoria, "KDT", 4) == 0)
    {
        solucion->cantidad_KDT ++;
    }
    if (actual->estado == 0)
    {
        solucion->cantidad_estado_0 ++;
    }
    else if (actual->estado == 1)
    {
        solucion->cantidad_estado_1 ++;
    }
    else
    {
        solucion->cantidad_estado_2 ++;
    }    
}

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){
    estadisticas_t *solucion = calloc(1, sizeof(estadisticas_t));
    if (usuario_id != 0)
    {
        for (int i = 0; i < largo; i++)
        {
            caso_t actual = arreglo_casos[i];
            usuario_t *usuario = actual.usuario;
            uint32_t id = usuario->id;
            if (id == usuario_id)
            {
                actualizar_estadisticas(solucion, &actual);
            }      
        }
    }
    else
    {
        for (int i = 0; i < largo; i++)
        {
            caso_t actual = arreglo_casos[i];
            actualizar_estadisticas(solucion, &actual);
        }  
    }    
    return solucion; 
}


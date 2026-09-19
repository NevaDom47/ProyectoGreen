Calculo de respuesta automatizada.



**1. Métrica principal: tiempo promedio de respuesta**



Para cada conversación registra:



fecha\_hora\_mensaje\_usuario

fecha\_hora\_primera\_respuesta\_proveedor

tiempo\_respuesta = primera\_respuesta - mensaje\_usuario



Ejemplo:



Atención	Usuario escribe	Proveedor responde	Tiempo

1	10:00	10:05	5 min

2	11:00	11:10	10 min

3	12:00	12:02	2 min

4	14:00	14:08	8 min

5	16:00	16:05	5 min



Promedio:



(5 + 10 + 2 + 8 + 5) / 5 = 6 minutos



Pero aquí viene lo interesante: 6 minutos no debería mostrarse directamente como porcentaje.



**2. Convertir el tiempo en un porcentaje**



Puedes establecer un tiempo de referencia o SLA de respuesta.



Por ejemplo:



Tiempo objetivo = 30 minutos



Entonces puedes calcular:



Índice de rapidez = 100 × (1 - TiempoPromedio / TiempoObjetivo)



Con 6 minutos:



100 × (1 - 6/30) = 80%



Pero esta fórmula tiene un problema: si tarda más de 30 minutos puede producir porcentajes negativos.



Por eso recomiendo utilizar una fórmula acotada:



Fórmula recomendada



% Rapidez = MAX(0, MIN(100, 100 × (1 - Tpromedio / Tobjetivo)))



Donde:



Tpromedio = tiempo promedio de respuesta.

Tobjetivo = tiempo considerado como respuesta máxima esperada.

MAX(0) evita valores negativos.

MIN(100) evita superar 100%.



**3. Sin embargo, hay una fórmula que me gusta más para tu aplicación**



Para un marketplace, recomiendo clasificar cada atención individualmente y después calcular el porcentaje de respuestas rápidas.



Por ejemplo:



Tiempo de respuesta	Clasificación	Puntos

0–5 min	⚡ Inmediata	100

>5–15 min	🟢 Muy rápida	90

>15–30 min	🟢 Rápida	75

>30–60 min	🟡 Moderada	50

>60–120 min	🟠 Lenta	25

>120 min	🔴 Muy lenta	0



Entonces cada conversación genera automáticamente una puntuación.



Ejemplo



Proveedor tiene 10 atenciones:



4 respuestas ≤ 5 min       → 100 puntos

3 respuestas ≤ 15 min      → 90 puntos

2 respuestas ≤ 30 min      → 75 puntos

1 respuesta > 120 min      → 0 puntos



Su índice sería:



(100 + 100 + 100 + 100 + 90 + 90 + 90 + 75 + 75 + 0) / 10



= 82%



En la aplicación podrías mostrar:



⚡ 82% de rapidez de respuesta

**4. Pero agregaría una segunda métrica**



Hay una diferencia importante entre:



“Qué tan rápido responde”



y



“Qué porcentaje de personas atiende”.



Un proveedor puede responder rápidamente a 8 de 10 usuarios y nunca responder a 2.



Por eso recomiendo tener:



Velocidad de respuesta



⚡ 82%



Tasa de respuesta



💬 95%



La tasa sería:



Tasa de respuesta = conversaciones respondidas / conversaciones recibidas × 100



Ejemplo:



100 conversaciones recibidas

95 respondidas



95 / 100 × 100 = 95%

**5. Hay un detalle MUY importante**



No recomiendo que el sistema simplemente tome todas las horas transcurridas.



Por ejemplo:



Usuario escribe viernes 11:00 PM

Proveedor responde sábado 8:00 AM



No necesariamente deberías considerar eso como 9 horas de demora, especialmente si el proveedor tiene un horario configurado.



Puedes registrar:



Horario de atención del proveedor

Lunes       8:00 AM – 6:00 PM

Martes      8:00 AM – 6:00 PM

Miércoles   8:00 AM – 6:00 PM

Jueves      8:00 AM – 6:00 PM

Viernes     8:00 AM – 6:00 PM

Sábado      9:00 AM – 1:00 PM

Domingo     Cerrado



Y calcular el tiempo efectivo de respuesta dentro del horario laboral.



Eso hace que el indicador sea mucho más justo.

**9. Mi propuesta final**

Yo mostraría algo así en el perfil:



⚡ Rapidez de respuesta: 91%

Responde habitualmente en menos de 15 minutos

**Arquitectura que te recomendaría**

&#x20;                 ATENCIÓN

&#x20;                    │

&#x20;         ┌──────────┴──────────┐

&#x20;         ↓                     ↓

&#x20;  ¿Fue respondida?       Tiempo respuesta

&#x20;         │                     │

&#x20;         ↓                     ↓

&#x20;  Tasa respuesta        Puntuación rapidez

&#x20;         │                     │

&#x20;         └──────────┬──────────┘

&#x20;                    ↓

&#x20;             ÍNDICE DE ATENCIÓN

&#x20;                    │

&#x20;         ┌──────────┴──────────┐

&#x20;         ↓                     ↓

&#x20;    Perfil proveedor       Estadísticas

&#x20;         │

&#x20;         ↓

&#x20;    "⚡ 94% atención"

Una mejora adicional que considero importante: calcular el indicador sobre una ventana móvil, por ejemplo las últimas 50 o 100 atenciones, en lugar de toda la vida del proveedor. Así, un proveedor que inicialmente tenía malos tiempos de respuesta puede mejorar su indicador progresivamente y uno que actualmente está respondiendo mal no queda protegido por un historial antiguo.


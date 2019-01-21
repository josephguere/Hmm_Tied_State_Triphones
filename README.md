# hmm_Tied_State_Triphones


#### PRÓLOGO IMPORTANTE
- Una vez adquiridos, los archivos wav deben copiarse en los directorios * data\train\wav *.

#### Paso 1 - Gramática de la tarea

* Para este tutorial, vaya a la carpeta '..\htk\dictionary' que creó en su directorio de inicio. Crea un nuevo directorio llamado 'Tutorial'. 

* A continuación, cree un archivo llamado sample.grammar en su nueva carpeta '..\htk\dictionary\Tutorial' y agregue el siguiente texto:

S : NS_B LOOKUP NS_E
LOOKUP: WORD

Para este tutorial, cree un archivo llamado: sample.voca en su carpeta '..\htk\dictionary\Tutorial' , y agregue el siguiente texto:

% NS_B
<s>        sil

% NS_E
</s>        sil

% WORD
achka a ch k a
ahorrayqa a h o rr a y al
…
…

Los archivos .grammar y .voca ahora deben compilarse en archivos " .dfa " y " .dict " para que Julius pueda usarlos. 
Descargue el script del compilador de gramática mkdfa.jl de Julia a su carpeta '..\htk\scripts' usando el siguiente comando.

julia D:\htk\scripts\mkdfa.jl D:\htk\dictionary\Tutorial\sample

Los archivos sample.dfa y sample.term generados contienen información finita de autómatas , y el   archivo sample.dict contiene información del diccionario de palabras. Todos están en formato julius.

Paso 2 – Diccionario de Pronunciación 

Crear un archi prompts.txt en la ruta '..\htk\dictionary\Tutorial' , que es la lista de palabras que registraremos en el siguiente Paso.

Derive un archivo wlist del archivo prompts.txt a la ruta '..\htk\dictionary' ; el archivo wlist es una lista ordenada de las palabras únicas que aparecen en el archivo prompts.txt.

El siguiente paso es agregar información de pronunciación (es decir, los fonemas que componen la palabra) a cada una de las palabras en el archivo wlist, creando así un diccionario de pronunciación.

Primero debe crear el script global.ded en su carpeta '..\htk\dictionary\Tutorial' (el script predeterminado utilizado por HDMan), que contiene:

AS sp 
RS cmu 
MP sil sil sp

Cree un nuevo directorio llamado 'léxico' en su carpeta '..\htk\dictionary'. Cree un nuevo archivo llamado quechua_lexicon en su carpeta '..\ htk\dictionary\lexicon' Ejecute el comando HDMan desde su directorio '..\htk\dictionary\Tutorial' de la siguiente manera:

HDMan -A -D -T 1 -m -w D:\htk\dictionary\lexicon\wlist.txt -n D:\htk\dictionary\bin\monophones1 -i -l dlog D:\htk\dictionary\bin\dict D:\htk\dictionary\lexicon\quechua_lexicon.txt

Por último, cree otro archivo de monophones para un paso posterior. Simplemente copie el archivo "monophones1" a un nuevo archivo "monophones0" en su directorio '..\htk\dictionary\bin' y luego elimine la entrada de "sp" de pausa corta en monophones0 .

Paso 3 - Grabar los datos

En este paso se deberá grabar el corpus para el entrenamiento del asr, podrán encontrar la lista de los audios entrando al siguiente enlace:  
https://siminchikkunarayku.pe/

Paso 4 - Creando los archivos de transcripción

Descargue el script de Julia prompts2mlf.jl a su directorio '..\htk\scripts' para generar el archivo mlf desde su archivo prompts.txt. Ejecute el script prompts2mlf desde su carpeta '..\htk\dictionary\Tutorial' de la siguiente manera:

julia D:\htk\scripts\prompts2mlf.jl D:\htk\dictionary\Tutorial\prompts.txt D:\htk\data\train\words.mlf

A continuación, debe ejecutar el comando HLEd para expandir las transcripciones de nivel de palabra a las transcripciones de nivel de phone, es decir, reemplazar cada palabra con sus fonemas y colocar el resultado en un nuevo archivo de etiqueta maestra de nivel de phone. Primero, cree el script de edición mkphones0.led en su carpeta '..\htk\dictionary\Tutorial'. Luego ejecute el siguiente comando:

HLEd -A -D -T 1 -l * -d D:\htk\dictionary\bin\dict -i D:\htk\data\train\phones0.mlf D:\htk\dictionary\Tutorial\mkphones0.led D:\htk\data\train\words.mlf
Que crea el archivo phones0.mlf en la carpeta '..\htk\data\train\' .

A continuación, debemos crear un segundo archivo phones1.mlf (que incluirá pausas cortas ("sp") después de cada grupo de teléfono de Word). Primero cree mkphones1.led en su carpeta '..\htk\dictionary\Tutorial' de la siguiente manera:

Luego ejecute el comando HLEd nuevamente desde su carpeta '..\htk\dictionary\Tutorial' de la siguiente manera:

HLEd -A -D -T 1 -l * -d D:\htk\dictionary\bin\dict -i D:\htk\data\train\phones1.mlf D:\htk\dictionary\tutorial\mkphones1.led D:\htk\data\train\words.mlf

Paso 5 - Codificación de los datos (audio)

Utiliza la herramienta HCopy para convertir sus archivos wav al formato MFCC. Tienes 2 opciones. Puede ejecutar el comando HCopy a mano para cada archivo de audio que creó en el Paso 3, o puede crear un archivo que contenga una lista de cada archivo de audio de origen y el nombre del archivo MFCC al que se convertirá, y usar ese archivo como un parámetro para el comando HCopy. Usaremos el segundo enfoque en este ejemplo. 

Cree el archivo de secuencia de comandos HTK codetrain.scp en su carpeta '..\htk\data\train'.

El comando HCopy realiza la conversión de formato wav a MFCC. Para hacer esto, se requiere un archivo de configuración (configuración) que especifique todos los parámetros de conversión necesarios. Cree un archivo llamado wav_config en su carpeta '..\htk\dictionary\Tutorial' .

Cree un nuevo directorio llamado 'mfcc' en su carpeta '..\htk\data\train' . Luego ejecute HCopy desde su carpeta '..\htk\dictionary\Tutorial' de la siguiente manera:

HCopy -A -D -T 1 -C D:\htk\dictionary\Tutorial\wav_config -S D:\htk\data\train\codetrain.scp

El resultado es la creación de una serie de archivos mfc correspondientes a los archivos enumerados en su script codetrain.scp en la carpeta '..\htk\data\train\mfcc'.

Paso 6 - Creando monofones de inicio plano

El primer paso en el entrenamiento del Modelo Oculto de Markov ("HMM") es definir un modelo de prototipo llamado "proto". El enfoque aquí es crear una estructura modelo, los parámetros no son importantes. Cree un archivo llamado proto en su directorio '..\ htk\models' .
 
También necesita un archivo de configuración. Cree un archivo llamado config en su directorio '..\htk\dictionary\Tutorial'.

El siguiente paso es crear una nueva carpeta llamada hmm0. También debe decirle a HTK dónde se encuentran todos los archivos vectoriales de características (esos son los archivos mfcc que creó en el último paso). Haces esto con un archivo de script HTK. Por lo tanto, crea un archivo llamado train.scp .

Luego cree una nueva versión de proto en la carpeta hmm0 - usando la herramienta HTK HCompV de la siguiente manera:

HCompV -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -f 0.01 -m -S D:\htk\data\train\train.scp -M D:\htk\models\hmm0 D:\htk\models\proto

Cree un nuevo archivo llamado hmmdefs en su carpeta ' ..\htk\models\hmm0':
•	Copiar el monophones0 archivo a la carpeta hmm0.
•	Renombra el archivo monophones0 a hmmdefs.
Para cada teléfono en hmmdefs:
•	Poner el teléfono entre comillas dobles; agregue '~ h' antes del teléfono (observe el espacio después de '~ h').
•	Copie desde la línea 5 (es decir, comience desde "<BEGINHMM>" hasta "<ENDHMM>") del archivo hmm0\proto y péguelo después de cada teléfono.
•	Deje una línea en blanco al final de su archivo.
Esto crea el archivo hmmdefs , que contiene monophones de "inicio plano".

El último paso en esta sección es crear el archivo de macros.

Debe crear y almacenar un nuevo archivo llamado macros en su carpeta '..\htk\models\hmm0' :

•	Crear un nuevo archivo llamado macros en hmm0.
•	Copiar vFloors a macros.
•	Copie las primeras 3 líneas de proto (de ~ o a <DIAGC>) y agréguelas al principio del archivo de macros.

Volver a estimarlos utilizando los archivos MFCC listados en el script train.scp y crear un nuevo conjunto de modelos en hmm1. Ejecute el comando HERest desde su directorio ‘..\htk\dictionary\Tutorial':

HERest -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\phones0.mlf -t 250.0 150.0 1000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm0\macros -H D:\htk\models\hmm0\hmmdefs -M D:\htk\models\hmm1 D:\htk\dictionary\bin\monophones0




HERest -A -D -T 1 -C D:\htk\dictionary\tutorial\config -I D:\htk\data\train\phones0.mlf -t 250.0 150.0 1000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm1\macros -H D:\htk\models\hmm1\hmmdefs -M D:\htk\models\hmm2 D:\htk\dictionary\bin\monophones0

HERest -A -D -T 1 -C D:\htk\dictionary\tutorial\config -I D:\htk\data\train\phones0.mlf -t 250.0 150.0 1000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm2\macros -H D:\htk\models\hmm2\hmmdefs -M D:\htk\models\hmm3 D:\htk\dictionary\bin\monophones0

Paso 7 - Arreglando los Modelos de Silencio

Primero copie el contenido de la carpeta hmm3 a hmm4. Luego, utilizando un editor, cree un nuevo modelo "sp" en '..\htk\models\hmm\hmmdefs ' de la siguiente manera:

•	Copie y pegue el modelo "sil" y cambie el nombre del nuevo "sp" (no borre su antiguo modelo "sil", lo necesitará, solo haga una copia)
•	Eliminar los estados 2 y 4 del nuevo modelo "sp" (es decir, mantener el "estado central" del antiguo modelo "sil" en el nuevo modelo "sp")
•	Cambiar <NUMSTATES> a 3
•	Cambiar <STATE> a 2
•	Cambia <TRANSP> a 3
•	Cambiar matriz en <TRANSP> a 3 por 3 matriz
•	Cambiar los números en la matriz de la siguiente manera:

0.0 1.0 0.0
0.0 0.9 0.1
0.0 0.0 0.0

A continuación, ejecute el editor de HMM llamado HHEd para "vincular" el estado sp al estado central central, ya que significa que uno o más HMM comparten el mismo conjunto de parámetros. Para hacer esto, necesita crear el siguiente script de comando HHEd, llamado sil.hed , en su carpeta '..\htk\dictionary\Tutorial ':

La última línea es el comando "empate". A continuación, ejecute HHEd de la siguiente manera, pero utilizando el archivo monophones1 que contiene el modelo sp:

HHEd -A -D -T 1 -H D:\htk\models\hmm4\macros -H D:\htk\models\hmm4\hmmdefs -M D:\htk\models\hmm5 D:\htk\dictionary\Tutorial\sil.hed D:\htk\dictionary\bin\monophones1

A continuación, ejecute HERest 2 veces más, esta vez con el archivo monophones1: 


HERest -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\phones1.mlf -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm5\macros -H D:\htk\models\hmm5\hmmdefs -M D:\htk\models\hmm6 D:\htk\dictionary\bin\monophones1

HERest -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\phones1.mlf -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm6\macros -H D:\htk\models\hmm6\hmmdefs -M D:\htk\models\hmm7 D:\htk\dictionary\bin\monophones1

Paso 8 - Realinear los datos de entrenamiento

Esta operación es similar a la operación de asignación de palabra a teléfono HLEd realizada en el Paso 4, sin embargo, en este caso, el comando HVite puede considerar todas las pronunciaciones de cada palabra, y luego mostrar la pronunciación que mejor coincida con los datos acústicos.

Ejecute el comando HVite de la siguiente manera:

HVite -A -D -T 1 -l * -o SWT -b SENT-END -C D:\htk\dictionary\Tutorial\config -H D:\htk\models\hmm7\macros -H D:\htk\models\hmm7\hmmdefs -i D:\htk\data\train\aligned.mlf -m -t 250.0 150.0 1000.0 -y lab -a -I D:\htk\data\train\words.mlf -S D:\htk\data\train\train.scp D:\htk\dictionary\bin\dict D:\htk\dictionary\bin\monophones1> HVite_log

A continuación, ejecuta HEREST 2 veces más:

HERest -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\aligned.mlf -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm7\macros -H D:\htk\models\hmm7\hmmdefs -M D:\htk\models\hmm8 D:\htk\dictionary\bin\monophones1

HERest -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\aligned.mlf -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm8\macros -H D:\htk\models\hmm8\hmmdefs -M D:\htk\models\hmm9 D:\htk\dictionary\bin\monophones1

Nota: los modelos de monophone creados en hmm9 podrían usarse con Julius para el reconocimiento de voz, pero la precisión del reconocimiento puede mejorarse enormemente mediante el uso de triphones de estado atado. Consulte las siguientes secciones.



Paso 9 - Haciendo Triphones de Monophones

Para convertir las transcripciones de monophone en el archivo alineado.mlf que creó en el Paso 8 en un conjunto equivalente de transcripciones de triphone, debe ejecutar el comando HLEd. HLEd se puede usar para generar una lista de todos los tonos de llamada para los cuales hay al menos un ejemplo en los datos de entrenamiento.

Primero necesitas crear el script de edición mktri.led. Luego ejecuta el comando HLEd de la siguiente manera:

HLEd -A -D -T 1 -n D:\htk\dictionary\bin\triphones1 -l * -i D:\htk\data\train\wintri.mlf D:\htk\dictionary\Tutorial\mktri.led D:\htk\data\train\aligned.mlf

A continuación, descargue el script Julia mktrihed.jl en su '..\htk\scripts', luego cree el archivo mktri.hed ejecutando el siguiente comando dentro de la carpeta 
'..\ htk\dictionary\bin':

julia D:\htk\scripts\mktrihed.jl monophones1 triphones1 D:\htk\dictionary\Tutorial\mktri.hed

Esto crea el archivo mktri.hed . Este archivo contiene un comando de clonación 'CL' seguido de una serie de comandos 'TI' para 'vincular' HMM para que compartan el mismo conjunto de parámetros. De esta manera, cuando volvemos a estimar estos nuevos parámetros vinculados (con HRest a continuación), los datos de cada uno de los parámetros originales no vinculados se agrupan para que se pueda obtener una mejor estimación. 

Luego crea 3 carpetas más: hmm10-12
A continuación, ejecute el comando HHEd:

HHEd -A -D -T 1 -H D:\htk\models\hmm9\macros -H D:\htk\models\hmm9\hmmdefs -M D:\htk\models\hmm10 D:\htk\dictionary\Tutorial\mktri.hed D:\htk\dictionary\bin\monophones1

A continuación, ejecuta HEREST 2 veces más:

HERest  -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\wintri.mlf -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm10\macros -H D:\htk\models\hmm10\hmmdefs -M D:\htk\models\hmm11 D:\htk\dictionary\bin\triphones1

HERest  -A -D -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\wintri.mlf -t 250.0 150.0 3000.0 -s D:\htk\models\hmm12\stats -S D:\htk\data\train\train.scp -H D:\htk\models\hmm11\macros -H D:\htk\models\hmm11\hmmdefs -M D:\htk\models\hmm12 D:\htk\dictionary\bin\triphones1
Paso 10 - Haciendo Triphones de Estado Atado

El agrupamiento de árboles de decisión utilizado aquí permite sintetizar triphones nunca vistos. ¿Cómo? mediante el uso de un árbol de decisión fonética donde los modelos se organizan en un árbol y los parámetros que usted pasa se llaman preguntas. El decodificador hace una pregunta sobre el contexto del teléfono y decide qué modelo usar.

Cree un nuevo archivo de script HTK llamado maketriphones.ded que contenga lo siguiente:

AS sp 
MP sil sil sp 
TC

Luego ejecute el comando HDMan contra todo el archivo de léxico, no solo el diccionario de entrenamiento que hemos utilizado hasta ahora:

HDMan -A -D -T 1 -b sp -n D:\htk\dictionary\bin\fulllist0 -g D:\htk\dictionary\Tutorial\maketriphones.ded -l flog D:\htk\dict-tri D:\htk\dictionary\lexicon\quechua_lexicon.txt

A continuación, descarga el script Julia fixfulllist.jl a la carpeta '..\htk\scripts' y ejecutarlo para anexar el contenido de monophones0 al principio de que la fulllist0 archivo, y luego a quitar las entradas duplicadas, y poner el resultado en   lista completa :

julia D:\htk\scripts\fixfulllist.jl D:\htk\dictionary\bin\fulllist0 D:\htk\dictionary\bin\monophones0 D:\htk\dictionary\bin\fulllist

A continuación, creará una nueva secuencia de comandos HTK llamada tree.hed (que contiene las preguntas de contexto del teléfono que HTK usará para seleccionar los tonos de llamada relevantes) en su carpeta '..\htk\dictionary\Tutorial' que contiene lo siguiente: tree1.hed (Nota: asegúrese de tener un espacio en blanco línea al final de este archivo). 

A continuación, descargue el script mkclscript.jl a su carpeta '..\htk\dictionary\bin' y ejecútelo de la siguiente manera para agregar los grupos de estado al archivo tree.hed que creó anteriormente:

julia D:\htk\scripts\mkclscript.jl D:\htk\dictionary\bin\monophones0 D:\htk\dictionary\Tutorial\tree.hed

A continuación, crea 3 carpetas más: hmm13-15
Luego ejecute el comando HHEd (editor de definición hmm):

HHEd -A -D -T 1 -H D:\htk\models\hmm12\macros -H D:\htk\models\hmm12\hmmdefs -M D:\htk\models\hmm13 D:\htk\dictionary\Tutorial\tree.hed D:\htk\dictionary\bin\triphones1

A continuación, ejecuta HEREST 2 veces más: 

HERest -A -D -T 1 -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\wintri.mlf  -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm13\macros -H D:\htk\models\hmm13\hmmdefs -M D:\htk\models\hmm14 D:\htk\tiedlist

HERest -A -D -T 1 -T 1 -C D:\htk\dictionary\Tutorial\config -I D:\htk\data\train\wintri.mlf  -t 250.0 150.0 3000.0 -S D:\htk\data\train\train.scp -H D:\htk\models\hmm14\macros -H D:\htk\models\hmm14\hmmdefs -M D:\htk\models\hmm15 D:\htk\tiedlist

¡El archivo hmmdefs en la carpeta hmm15, junto con el archivo de lista enlazada, ahora se puede usar con Julius para reconocer su discurso!

Corriendo julius en vivo

Primero necesitas crear tu archivo de configuración de Julius. Copie este archivo de configuración de muestra (sample.jconf) en su carpeta '..\htk'. Para obtener detalles sobre los parámetros contenidos en el archivo Sample.jconf, consulte el Juliusbook para obtener más información. 

Asegúrese de que el volumen de su micrófono sea similar al de cuando creó sus archivos de audio. Luego corre Julius con:

C:> julius-4.3.1 -input mic -C Sample.jconf

 


# Metodo di equalizzazione dell’istogramma di una immagine

Corso: Reti Logiche.

Il progetto richiesto consiste nell’implementazione in VHDL del metodo di codifica basato sul metodo di equalizzazione dell’istogramma di una immagine. 

L’obiettivo è quello di ricalibrare il contrasto quando i valori di intensità dell’immagine risultano troppo ravvicinati. Si tratta di un processo che cerca di distribuire in modo uniforme l'intervallo dinamico dei valori di intensità dell'immagine, migliorando così la sua qualità visiva.

Nella versione sviluppata è richiesta l’implementazione dell’algoritmo solo per immagini in scala di grigi a 256 livelli. Come da specifica funzionale del progetto, ad ogni indirizzo corrisponde un pixel dell’immagine. La dimensione della stessa è definita da 2 byte, ognuno di 8 bit, memorizzati rispettivamente all’indirizzo 0, per quanto riguarda la dimensione di colonna, e all’indirizzo 1, per quanto riguarda la dimensione di riga.

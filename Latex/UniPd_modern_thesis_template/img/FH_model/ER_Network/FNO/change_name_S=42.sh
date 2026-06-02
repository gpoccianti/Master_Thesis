#!/bin/bash

# Itera su tutti i file .png che contengono "_S=42" nella cartella corrente
for file in *"_S=42"*.png; do
    # Verifica che il file esista (evita errori se nessun file corrisponde al criterio)
    if [[ -f "$file" ]]; then
        # Genera il nuovo nome sostituendo "_S=42" con una stringa vuota
        nuovo_nome="${file//_S=42/}"
        
        # Rinomina il file
        mv "$file" "$nuovo_nome"
        
        # Mostra un messaggio a video per confermare l'operazione
        echo "Rinominato: '$file' -> '$nuovo_nome'"
    fi
done

echo "Operazione completata!"
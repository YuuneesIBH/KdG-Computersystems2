#!/bin/bash

#########################################################
# Antwoorden op de vragen:
#
# a) Output bij gewoon uitvoeren van stream.sh:
#    A       (stdout)
#    B       (stderr)
#    C       (2>&1 zorgt dat foutmelding eventueel naar stdout gaat, maar hier overbodig)
#    D       (omdat stdout → stderr)
#    Hello World (stdout)
#
# b) Output bij: ./stream.sh 1>tekst.txt
#    Op scherm (stderr): B, D
#    In tekst.txt (stdout): A, C, Hello World
#
# c) Output bij: ./stream.sh 2>tekst.txt
#    Op scherm (stdout): A, C, Hello World
#    In tekst.txt (stderr): B, D
#
# d) echo "C" 2>&1 heeft geen zin:
#    Omdat echo "C" standaard al naar stdout gaat. 
#    2>&1 verandert stderr naar stdout, maar hier is geen stderr actief.
#
# e) Na toevoegen van `command -V tralala`:
#    - Geeft fout via stderr (tralala niet gevonden)
#    - Bij b (1>tekst.txt): fout blijft zichtbaar op scherm
#    - Bij c (2>tekst.txt): fout wordt naar tekst.txt gestuurd
#
# f) Na toevoegen van `command -V bash`:
#    - Geeft pad naar bash via stdout
#    - Bij b (1>tekst.txt): pad komt in tekst.txt
#    - Bij c (2>tekst.txt): pad wordt getoond op scherm
#########################################################

echo "A" >&1          # stdout
echo "B" >&2          # stderr
echo "C" 2>&1         # zou stderr naar stdout sturen, maar hier overbodig
echo "D" 1>&2         # stdout wordt stderr
echo "Hello World"    # stdout

# e) Probeer ook:
# command -V tralala  # fout via stderr

# f) En:
# command -V bash     # correct pad via stdout
# Praktikum 6 - Protsessid ja signaalid

Ülesanne 1.

<img width="807" height="738" alt="Ulesanne 1" src="https://github.com/user-attachments/assets/1f80426a-29a9-4ef9-a4f1-34b1439a6965" />


Ülesanne 2.

<img width="935" height="718" alt="Ulesanne 2" src="https://github.com/user-attachments/assets/b18b614b-a934-4639-a005-20e22bc4039d" />


Ülesanne 3.

<img width="1405" height="717" alt="Ulesanne 3" src="https://github.com/user-attachments/assets/1ee6c42a-2cb1-43ef-93b7-923fb2199bba" />


Ülesanne 4.

<img width="1411" height="426" alt="Ulesanne 4" src="https://github.com/user-attachments/assets/c72bbd45-eb5d-4d25-9d3c-709e7fe80d55" />


Ülesanne 5.

WM_COMMAND (ID = 273)
See sõnum tuleb siis, kui kasutaja teeb aknas mingi tegevuse. Näiteks vajutab nuppu või valib menüüst käsu. Failis olid wParam = 2448 ja lParam = 1706384. Need väärtused näitavad, milline nupp või juhtosa saadab sõnumi (wParam) ja millise akna kaudu (lParam). Sõnum saadeti hetkel, kui vajutati nuppu, et põhiaken teaks, et midagi tehti.
Allikas: https://learn.microsoft.com/en-us/windows/win32/winmsg/about-messages-and-message-queues

WM_CLOSE (ID = 16)
See sõnum saadetakse, kui kasutaja sulgeb akna. Näiteks vajutades 'X' nupu akna paremas ülanurgas. Kui protsess saab selle sõnumi, käivitab ta oma sulgemisprotsessi. Parameetrid olid wParam = 0, lParam = 0, sest see sõnum ei vaja lisainfot.
Allikas: https://learn.microsoft.com/en-us/windows/win32/winmsg/wm-close

Suutsin tekitada '???' sõnumeid: 
522,"???",7864328,35258895 
19,"???",0,0



       IDENTIFICATION DIVISION.
       PROGRAM-ID. WEBHELLO.

       PROCEDURE DIVISION.

           DISPLAY "Content-Type: text/html".
           DISPLAY SPACE.

           DISPLAY "<html>".
           DISPLAY "<head><title>COBOL Web</title></head>".
           DISPLAY "<body>".
           DISPLAY "<h1>Bonjour COBOL Web</h1>".
           DISPLAY "<button>Valider</button>".
           DISPLAY "</body>".
           DISPLAY "</html>".

           GOBACK.
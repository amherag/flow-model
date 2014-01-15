(ql:quickload "cl-json")
(ql:quickload "drakma")
(ql:quickload "hunchentoot")
(ql:quickload "cl-who")
(ql:quickload "restas")
(ql:quickload "restas-directory-publisher")
(ql:quickload "restas.file-publisher")
(ql:quickload "sqlite")

(load "cl-docker.lisp")
(load "model.lisp")

(restas:define-module :experiment (:use :cl :cl-who :alexandria :hunchentoot))
(in-package :experiment)

(setf cl-who:*prologue* "<!DOCTYPE html>")
(setf *session-max-time* 999999)
(setf drakma:*text-content-types* (cons '("application" . "json") drakma:*text-content-types*))
(setf hunchentoot:*catch-errors-p* nil)
(setf hunchentoot:*show-lisp-errors-p* t)
;;(setf hunchentoot:*show-lisp-backtraces-p* nil)
(defparameter *success-authenticated-user-uri* 'experiment)
(defparameter *fail-authenticated-user-uri* 'login)

(defclass single-acceptor (restas:restas-acceptor)
  ((taskmaster :initarg :taskmaster :initform 'hunchentoot:single-threaded-taskmaster)))

;;(restas:start :experiment :port 8080 :acceptor-class 'single-acceptor)
(restas:start :experiment :port 8080)

(restas:mount-module -img- (#:restas.directory-publisher)
  (:url "/img/")
  (restas.directory-publisher:*directory* #P "img/")
  (restas.directory-publisher:*autoindex* t))

(restas:mount-module -css- (#:restas.directory-publisher)
  (:url "/css/")
  (restas.directory-publisher:*directory* #P "css/")
  (restas.directory-publisher:*autoindex* t))

(restas:mount-module -js- (#:restas.directory-publisher)
  (:url "/js/")
  (restas.directory-publisher:*directory* #P "js/")
  (restas.directory-publisher:*autoindex* t))

;;;;;;;;;;;;;;;;
;;ROUTES;;
;;;;;;;;;;;;;;;;

(restas:define-route authentication/get ("authentication")
  (restas:redirect *fail-authenticated-user-uri*))

(restas:define-route authentication ("authentication" :method :post)
    (if (or (session-value :user)
	    (and (> (length (post-parameter "username")) 2)
	     (setf (session-value :user)
		       (post-parameter "username"))))
	(restas:redirect *success-authenticated-user-uri*)
	(restas:redirect *fail-authenticated-user-uri*)))

(restas:define-route login ("")
  (if (session-value :user)
      (restas:redirect *success-authenticated-user-uri*)
      (with-html-output-to-string (out)
	(:html (:head (:title "Flow Model")
		      (:link :href "css/bootstrap/bootstrap.min.css" :rel "stylesheet" :media "screen")
		      (:link :href "css/main/login.css" :rel "stylesheet" :media "screen"))
	       (:body (:div :class "container"
			    (:form :class "form-signin" :method "post" :action "authentication"
				   (:h2 :class "form-signin-heading" "Autentif&iacute;quese")
				   (:input :type "text" :name "username" :class "input-block-level" :placeholder "Usuario")
				   (:input :type "password" :name "password" :class "input-block-level" :placeholder "Contrase&ntilde;a")
				   (:button :class "btn btn-large btn-primary" :type "submit" "Entrar")))
		      (:script :src "js/jquery/jquery.js")
		      (:script :src "js/bootstrap/bootstrap.min.js"))))))

(restas:define-route login ("")
  (if (session-value :user)
      (restas:redirect *success-authenticated-user-uri*)
      (with-html-output-to-string (out)
	(:html (:head (:title "Flow Model")
		      (:link :href "css/bootstrap/bootstrap.min.css" :rel "stylesheet" :media "screen")
		      (:link :href "css/main/login.css" :rel "stylesheet" :media "screen"))
	       (:body (:div :class "container"
			    (:form :class "form-signin" :method "post" :action "authentication"
				   (:h2 :class "form-signin-heading" "Escribe tu nombre completo")
				   (:input :type "text" :name "username" :class "input-block-level" :placeholder "Nombre Completo")
				   (:button :class "btn btn-large btn-primary" :type "submit" "Entrar")))
		      (:script :src "js/jquery/jquery.js")
		      (:script :src "js/bootstrap/bootstrap.min.js"))))))

(restas:define-route logout ("logout")
  (if *session*
      (remove-session *session*))
  (restas:redirect *fail-authenticated-user-uri*))

(restas:define-route its ("its" :method :post)
  (alexandria:if-let ((username (session-value :user)))
    (let* ((active-step (post-parameter "step"))
	   (solution (model:get-solution active-step))
	   (user-code (post-parameter "code"))
	   (test-result
	    (format nil "(~a (quote ~a))"
		    solution user-code)))
      (format nil "~a~%~%~a"
	      (let ((r (car (last (cl-ppcre:split "\\n" (docker:run-container test-result))))))
		(cond ((string= r "true") "¡Bien hecho!")
		      (t "Intenta de nuevo")))
	      (docker:run-container user-code)
	      )
      )))

#|
(dotimes (x 100)
(bordeaux-threads:make-thread
 (lambda ()
   (drakma:http-request "http://localhost:8080/its" :method :post
			:parameters '(("step" . "3") ("code" . "(dotimes (x 3000000000) x)")))
   )))
|#

(restas:define-route result ("result" :method :post)
  (alexandria:if-let ((username (session-value :user))
		      (result (post-parameter "result")))
    (model:post-result result)))

(restas:define-route experiment ("/experiment")
  (if (session-value :user)
      (with-html-output-to-string (out)
	(:html (:head (:title "Flow Model")
		      (:meta :http-equiv "content-type" :content "text/html; charset=utf-8")
		      (:link :href "/css/codemirror/codemirror.css" :rel "stylesheet")
		      (:link :href "/css/codemirror/theme/eclipse.css" :rel "stylesheet")
		      (:link :href "/css/bootstrap/bootstrap-responsive.css" :rel "stylesheet")
		      (:link :href "/css/main/its.css" :rel "stylesheet")
		      (:link :href "/css/jquery-ui/ui-lightness/jquery-ui.css" :rel "stylesheet")
		      (:script :src "/js/jquery/jquery.js")
		      (:script :src "/js/main/jmpress.js")
		      (:script :src "/js/codemirror/codemirror.js")
		      (:script :src "/js/codemirror/addon/selection/active-line.js")
		      (:script :src "/js/codemirror/addon/edit/matchbrackets.js")
		      (:script :src "/js/codemirror/keymap/emacs.js")
		      (:script :src "/js/main/keymap/its-keymap.js")
		      (:script :src "/js/codemirror/mode/commonlisp/commonlisp.js")
		      (:script :src "/js/bootstrap/bootstrap.js")
		      (:script :src "/js/jquery-ui/jquery-ui.js")
		      (:script :src "/js/main/its-before.js"))
	       (:body
		(:div :class "container-liquid"
		      (:div :id "flowquestion" :class "row-fluid" :style "display: none; margin: 150px 0 0 200px; font-size: 16pt;"
			    (:div :id "flowslider"
				  (:form :action "#"
					 (:div (:label :for "difficulty" "¿Qué dificultad crees que tuvo este ejercicio?"))
				  (:div (:select :id "difficulty" :style "margin-bottom: 30px; font-size: 12pt;"
				   (:option :value "tooeasy" "Muy fácil")
				   (:option :value "easy" "Fácil")
				   (:option :value "normal" "Normal")
				   (:option :value "hard" "Difícil")
				   (:option :value "toohard" "Muy difícil")))
				  (:div (:label :for "mentalstate" "¿Cómo te sientes después de realizar este ejercicio?"))
				  (:div (:select :id "mentalstate" :style "margin-bottom: 30px; font-size: 12pt;"
						 (:option :value "flow" "Quiero m&aacute;s ejercicios")
						 (:option :value "arousal" "Atento")
						 (:option :value "anxiety" "Desesperado")
						 (:option :value "apathy" "No me interesa")
						 (:option :value "relaxation" "Relajado")
						 (:option :value "control" "Todo bajo control")
						 (:option :value "worry" "Se me est&aacute; dificultando")
						 (:option :value "boredom" "Aburrido")
				   ))
				  (:button :style "font-size: 14pt;" :id "survey" "¡Continuar!"))))
		      (:div :id "tohide" :style "display: block;"
			    (:div :class "row-fluid"
				  (:div :id "jmpress"
					(dolist (x (load-steps))
					  (format out x))))
			    (:input :id "activestep" :type "hidden" :value "1")
			    (:input :id "user" :type "hidden" :value (session-value :user))
			    (:div :id "editor" :style "visibility: hidden;"
				  (:div :class "row-fluid" :style "height: 30px; padding-top: 10px;"
					"Presiona Ctrl+Enter para evaluar tu código.")
				  (:div :class "row-fluid"
					(:div :class "span6" :id "inputAreaContainer"
					      (:textarea :id "inputArea" :name "codeArea" ""))
					(:div :class "span6" :id "reviewAreaContainer"
					      (:textarea :id "reviewArea" :name "reviewArea" "Aquí aparecerán el resultado de tu código y si lo hiciste bien o no."))))))
		(:script :src "/js/main/its.js")
		)))
      (restas:redirect *fail-authenticated-user-uri*)))

;;				  (:label :for "flow" "¿Qué tan motivado te sientes después de haber concluido con este paso en el tutorial?
;;Una motivación de 0 significaría “nada motivado”, y una motivación de 100 significaría “totalmente motivado”")
;;				  (:br)
;;				  (:input :type "text" :id "flow" :style "border:0; color:#f6931f; font-weight:bold; font-size: 20pt;")

(defun load-steps ()
  (let ((exercises (model:get-exercises))
	(x -2000)
	(step 0))
    (mapcar (lambda (exercise)
	      (let ((title (second exercise))
		    (content (third exercise))
		    (coding? (fourth exercise)))
		(cl-who:with-html-output-to-string (out)
		  (:div :class "step" :data-x (incf x 2000) :data-y 0
			(format out "~a~a~a~a"
				(format nil "<h1>~a</h1>" title)
				(format nil "<p>~a</p>" content)
				
				(format nil "
<script>
$(function() {
$('#step-~a')
	.on('enterStep', function(event) {
           $('#activestep').val('~a');
if(~a) {
           $('#editor').css('visibility', 'visible');
           inputArea.focus();
} else {
           $('#editor').css('visibility', 'hidden');
}
	})
})
</script>" (incf step) step coding?)
(if (string= coding? "false")
				    (cl-who:with-html-output-to-string (out)
				      (:button :class "next" :style "font-size: 12pt;" "Siguiente"))
				      "")
				))
		  )))
exercises)))

;;(load-steps)

#|

(progn
(model:post-exercise "1" "Introducci&oacute;n"
"newLISP es un lenguaje interpretado, de prop&oacute;sito general, de la familia de los lenguajes Lisp. Trabaja especialmente bien para aplicaciones de inteligencia artificial, simulaci&oacute;n, procesamiento de lenguaje natural, big data, aprendizaje autom&aacute;tico y estad&iacute;stica. Con este tutorial aprender&aacute;s un poco de newLISP." "" nil)

(model:post-exercise "2" "Cadenas de Caracteres (Ejercicio 1 de 6)"
		     "<div>Escribe una cadena de caracteres.</div>
<h2>Condiciones:</h2>
<ul><li>Debe ser un texto encerrado entre comillas dobles</li>
<li>Debe tener mas de 5 letras</li></ul>
<h2>Ejemplo:</h2>
<div>\"esto es una cadena de caracteres.\"</div>
<h2>Notas:</h2>
<ul><li>Ten cuidado de no poner comillas sencillas (esta:  '  ) o comillas estilizadas (estas:  “ ” )</li>
</ul>"
		     "(fn (x) (and (string? x) (> (length x) 5)))" t)

(model:post-exercise "3" "N&uacute;meros (Ejercicio 2 de 6)"
		     "<div>Escribe un n&uacute;mero.</div>
<h2>Condiciones</h2><ul>
<li>Debe ser mayor que 100</li>
<li>Debe ser menor que 500</li></ul>
<h2>Ejemplo:</h2>
<div>3123131</div>
"
		     "(fn (x) (and (number? x) (> x 100) (< x 500)))"
		     t)

(model:post-exercise "4" "Funci&oacuten de Suma (Ejercicio 3 de 6)"
		     "<div>La función de suma (+) toma una lista de números y regresa la suma de estos. Haz una suma.</div>
<h2>Condiciones</h2><ul>
<li>Solo puedes sumar cuatro números. Ejemplo: (+ 1 2 3 4)</li>
<li>El primer número debe ser mayor que 15.</li>
<li>El segundo número debe ser menor que 30.</li>
<li>La suma de los cuatro números debe ser igual a 45.</li>
<li>Ten cuidado de poner un espacio después del signo de +, o sea, (+ 1 2) y no (+1 2).</li>
</ul>
<h2>Ejemplo:</h2>
<div>(+ 10 10 10 10 10)</div>
"
		     "(fn (x) (and (= (first x) '+) (= (length (rest x)) 4) (> (nth 1 x) 15) (< (nth 2 x) 30) (= (eval x) 45)))"
		     t)

(model:post-exercise "5" "Sumas Anidadas (Ejercicio 4 de 6)"
		     "<div>La función de suma, (+), puede anidarse. De esta forma, el resultado de una suma sirve como argumento de otra suma.</div>
<h2>Condiciones</h2><ul>
<li>Vuelve a ver el ejemplo hasta que lo entiendas bien. Te lo recomiendo.</li>
<li>Debes hacer una suma anidada. Si haces una suma normal no pasar&aacute;s la prueba.</li>
<li>El resultado de la suma puede ser lo que sea.</li>
</ul>
<h2>Ejemplo:</h2>
<div>(+ 15 15 (+ 10 10) 15)</div>
"
		     "(fn (z) (and (list? z) (not (= (flat z) z)) (number? (eval z)) (for-all true? (flat ((define (nest x) (if (= (first x) '+) (map (fn (y) (cond ((number? y) true) ((list? y) (nest y)))) (rest x)))) z)))))"
		     t)

(model:post-exercise "6" "Listas (Ejercicio 5 de 6)"
		     "<div>Las listas en newLISP comienzan por una comilla ' seguido por par&eacute;ntesis que contienen a los elementos de la lista. La comilla es esta    '    y no esta   `.</div>
<h2>Condiciones</h2><ul>
<li>La lista debe tener entre 5 y 7 elementos, o sea, 5, 6 o 7 elementos. No m&aacute;s, no menos.</li>
<li>Todos los elementos deben ser o n&uacute;meros o cadenas de caracteres.</li>
<li>No hagas una lista anidada (aun no lo hemos visto)</li>
</ul>
<h2>Ejemplo:</h2>
<ul>
<li>'(1 2 3 4)</li>
<li>'(\"hola\" \"como\" \"estas\")</li>
</ul>
"
		     "(fn (x) (define x (eval x)) (and (list? x) (= (flat x) x) (and (> (length x) 4) (< (length x) 8)) (for-all (fn (y) (or (number? y) (string? y))) x)))"
		     t)

(model:post-exercise "7" "Listas Anidadas (Ejercicio 6 de 6)"
		     "<div>Las listas anidadas son listas dentro de otras listas. Es parecido a lo que hiciste en el ejercicio de sumas anidadas, solo que ahora las listas pueden tener cualquier elemento, y no ser forzosamente sumas. Igual que las listas sin anidar, las listas anidadas comienzan con una comilla '</div>
<h2>Condiciones</h2><ul>
<li>La lista anidada debe tener como m&iacute;nimo dos elementos</li>
<li>Debe ser una lista anidada</li>
<li>La lista anidada puede tener elementos de cualquier tipo</li>
</ul>
<h2>Ejemplo:</h2>
<ul>
<li>'(1 \"dos\" \"tres\" 4 (5 6 \"siete\" 8 9))</li>
</ul>
"
		     "(fn (x) (define x (eval x)) (and (list? x) (not (= (flat x) x)) (> (length x) 1)))"
		     t)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

|#

#|

(model:post-exercise "4" "Imprimir una Cadena de Caracteres (Ejercicio 3 de 8)"
		     "<div>Imprime una cadena de caracteres usando la funci&oacute;n \"println\".</div>
<h2>Ejemplo:</h2>
<div>(println \"hola, mundo!\")</div>
<h2>Condiciones</h2><ul>
<li>Debes usar la funci&oacute;n \"println\"</li>
<li>Debes imprimir una cadena de caracteres (y no un n&uacute;mero, por ejemplo)</li>
<li>Tu c&oacute;digo debe estar entre par&eacute;ntesis. O sea, (println \"hola\") y no println \"hola\"</li></ul>"
		     "(fn (x) (and (= (first x) 'println) (string? (nth 1 x))))"
		     t)

(model:post-exercise "7" "Condiciones (Ejercicio 6 de 8)"
		     "<div>En newLISP las condiciones se hacen con la funci&oacute;n (if). Primero se escribe if, después la condición, después el código que quieres que se ejecute si la condición es verdadera y por último el código que quieres que se ejecute si la condición es falsa.</div>
<h2>Ejemplo:</h2>
<ul>
<li>(if true 10 5)      =>     10</li>
<li>(if false \"hola\" \"adios\")      =>     \"adios\"</li>
</ul>
<h2>Condiciones</h2><ul>
<li>El código que se ejecuta en la parte verdadera debe dar como resultado 20</li>
<li>El código que se ejecuta en la parte falsa debe dar como resultado un número impar</li>
<li>Para la condición te recomiendo que uses true o false. No es “true” o “false” entre comillas, sólo      true       y      false</li>
</ul>"
		     "(fn (x) (and (= (first x) 'if) (= (eval (nth 2 x)) 20) (= (% (eval (nth 3 x)) 2) 1)))"
		     t)

(model:post-exercise "2" "&iexcl;Hola, mundo!" "Como primer ejercicio, imprimiremos el cl&aacute;sico \"&iexcl;Hola, Mundo!\". Escribe (println \"Hola Mundo!\") o cualquier texto que quieras en la caja de texto de arriba y despu&eacute;s presiona la combinaci&oacute;n de teclas \"Ctrl+Enter\"." "(fn (x) (and (list? x) (= (first x) 'println) (string? (nth 1 x))))" t)

(model:post-exercise "3" "Funciones en newLISP" "En newLISP, como en todos los lenguajes de programaci&oacute;n de la familia de los Lisp, todas las funciones se escriben en prefijo. De esta forma, en lugar de escribir funcion(arg1, arg2), en Lisp escribir&iacute;amos (funcion arg1 arg2). Esto, aunque confunde a muchos, resulta en varias ventajas. ¡Practiquemos unas cuantas funciones en prefijo!" nil nil)

(model:post-exercise "4" "Sumando dos N&uacute;meros" "Vamos a sumar dos n&uacute;meros, los que quieras. Para hacer esto, escribe tu c&oacute;digo en la caja de arriba como lo hiciste antes, algo parecido a (+ 1 2). Si&eacute;ntete con la libertad de poner los n&uacute;meros que quieras." "(fn (x) (and (list? x) (= (length x) 3) (= (first x) '+) (number? (nth 1 x)) (number? (nth 2 x))))" t)

(model:post-exercise "5" "Sumando muchos números" "En otros lenguajes de programación, si quisiéramos sumar más de dos números necesitaríamos poner muchos signos de +. Por ejemplo: 3 + 4 + 7 + 8. En newLISP y en otros Lisp, no necesitamos hacer esto. Escribe en la caja de texto de arriba una suma, tal como en el ejercicio anterior, pero ahora con muchos números. Por ejemplo: (+ 1 2 3 4 5)" "(fn (x) (and (list? x) (= (first x) '+) (> (length x) 3) (for-all number? (rest x))))" t)

(model:post-exercise "6" "Anidando Funciones" "newLISP usa principalmente el paradigma de programación funcional. Esto, entre otras muchas cosas, significa que ver funciones actuando como argumentos de otras funciones es algo común. Prueba anidar algunas sumas, por ejemplo: (+ 1 (+ 2 3)) primero sumaría 2 + 3, lo que nos da 5, y después sumaría éste 5 con el 1, dándonos 6." "(fn (z) (and (list? z) (not (= (flat z) z)) (for-all true? (flat ((define (nest x) (if (= (first x) '+) (map (fn (y) (cond ((number? y) true) ((list? y) (nest y)))) (rest x)))) z)))))" t)

(model:post-exercise "7" "Código Fuente y Datos" "Lo que hizo famosos a los Lisp en los años 70-80 era su notable característica de tratar al código fuente como datos, y tratar a los datos como código fuente. Así es, no hay ninguna diferencia entre datos y el código fuente que has estás escribiendo. Esto hace que newLISP pueda ser un lenguaje de programación que crea programas, que a su vez crean programas, que a su vez pueden crear más programas, los cuales pueden crear otros programas…
<br /><br />
Esta característica hizo pensar a muchos científicos que podrían crear un programa en Lisp que fuera lo suficientemente inteligente como para que se siguiera creando a sí mismo. Lamentablemente esto no pasó, ¡pero no fue culpa de Lisp!" nil nil)

(model:post-exercise "8" "Tratando el Código Fuente como Datos" "Juguemos un poco con los datos y el código fuente. Primero, escribe en la caja de texto (println “hola”). Después, escribe ‘(println “hola”), nota que hay una comilla antes del (println “hola”)! Por último, escribe un número impar en la terminal para continuar." "(fn (x) (integer? x))" t)

(model:post-exercise "9" "Pero, ¿qué fue lo que pasó?" "Lo que ocurrió es que (println “hola”) imprimió “hola”, tal como cualquier otro lenguaje lo hubiera hecho. Sin embargo, ‘(println “hola”), con la comilla, regresa esa misma expresión como resultado. Es como decirle a la computadora “Este código fuente NO lo evalúes, sino úsalo como un dato para otro proceso”." nil nil)

(model:post-exercise "10" "Listas" "Sé que ustedes aún no han visto esta estructura de datos, porque me lo dijo el Doctor Mario, pero no veremos el tema de una forma profunda.
<br /><br />
Lisp originalmente era llamado \“LISP\", el cual era un acrónimo de LISt Processing. La lista era una estructura de datos tan importante y poderosa en LISP, que incluso los programas hechos en LISP eran listas internamente. En los Lisp modernos ya no es así, pero conservaron la sintaxis debido a su poder. Veamos algunos ejemplos." nil nil)

(model:post-exercise "11" "Lista de Números" "Este es el último ejercicio. Te voy a dar un ejemplo de una lista, y después vas a crear una lista que cumpla con las características que te dé. Ejemplo: ‘(“uno” “dos” “tres”). Nota que inicia con una comilla y los elementos no están separados por comas, sino por espacios, tal como en una función normal. Esta es una lista de tres elementos, donde todos son cadenas de caracteres. Para terminar, escribe una lista de CINCO (5) NÚMEROS (pista: tiene que tener 5 elementos, y todos tienen que ser números)." "(fn (x) (and (list? x) (for-all number? x) (= (length x) 5)))" t)

(model:post-exercise "12" "Fin" "&iexcl;Gracias por tu participación!" nil nil)
)

|#


;;(dotimes (x 10)
;;  (bordeaux-threads:make-thread (lambda ()
;;				  (docker:run-container "(dotimes (x 100000000) x)"))))

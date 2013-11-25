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
  (let* ((username (post-parameter "username"))
	 (password (model:hash-password (post-parameter "password"))))
    (if (or (session-value :user)
	    (and username password
		 (string= (model:get-user/password username) password)
		 (setf (session-value :user) username)))
	(restas:redirect *success-authenticated-user-uri*)
	(restas:redirect *fail-authenticated-user-uri*))))

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

(restas:define-route logout ("logout")
  (if *session*
      (remove-session *session*))
  (restas:redirect *fail-authenticated-user-uri*))

(restas:define-route its ("its" :method :post)
  (alexandria:if-let ((username (session-value :user)))
    (let* ((active-step (post-parameter "step"))
	   (solution (model:get-solution active-step))
	   (user-code (post-parameter "code"))
	   (code-string
	    (format nil "(list ~a (~a ~a))"
		    user-code solution user-code)))
      (docker:run-container (docker:create-container :command code-string)))))

(restas:define-route experiment ("/experiment")
  (if (session-value :user)
      (with-html-output-to-string (out)
	(:html (:head (:title "Flow Model")
		      (:meta :http-equiv "content-type" :content "text/html; charset=utf-8")
		      (:link :href "/css/codemirror/codemirror.css" :rel "stylesheet")
		      (:link :href "/css/codemirror/theme/eclipse.css" :rel "stylesheet")
		      (:link :href "/css/bootstrap/bootstrap-responsive.css" :rel "stylesheet")
		      (:link :href "/css/main/its.css" :rel "stylesheet")
		      (:script :src "/js/jquery/jquery.js")
		      (:script :src "/js/main/jmpress.js")
		      (:script :src "/js/codemirror/codemirror.js")
		      (:script :src "/js/codemirror/addon/selection/active-line.js")
		      (:script :src "/js/codemirror/addon/edit/matchbrackets.js")
		      (:script :src "/js/codemirror/keymap/emacs.js")
		      (:script :src "/js/main/keymap/its-keymap.js")
		      (:script :src "/js/codemirror/mode/commonlisp/commonlisp.js")
		      (:script :src "/js/bootstrap/bootstrap.js")
		      (:script :src "/js/main/its-before.js"))
	       (:body
		(:div :class "container-liquid"
		      (:div :class "row-fluid"
			    (:div :id "jmpress"
				  (dolist (x (load-steps))
				    (format out x))))
		      (:input :id "activestep" :type "hidden" :value "#step-1")
		      (:div :class "row-fluid"
			    "Presiona Ctrl+Enter o el bot&oacute;n \"Evaluar\" para evaluar tu c&oacute;digo."
			    (:button :class "next" "Siguiente"))
		      (:div :class "row-fluid"
			    (:div :class "span6" :id "inputAreaContainer"
				  (:textarea :id "inputArea" :name "codeArea" ""))
			    (:div :class "span6" :id "reviewAreaContainer"
				  (:textarea :id "reviewArea" :name "reviewArea")))		      
		      )
		(:script :src "/js/main/its.js"))))
      (restas:redirect *fail-authenticated-user-uri*)))



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
			(format out "~a~a~a"
				(format nil "<h1>~a</h1>" title)
				(format nil "<p>~a</p>" content)
				(format nil "
<script>
$(function() {
$('#step-~a')
	.on('enterStep', function(event) {
           $('#activestep').val('#step-~a')
	})
})
</script>" (incf step) step)

				))
		  )))
	    exercises)))

;;(load-steps)

#|
(:div :class "step"
      :data-x "0" :data-y "0"
      (:div :class "row-fluid"
	    (str (step1))
	    (:div :class "row-fluid"
		  (:button :class "next" "Siguiente"))))

(:div :class "step"
      :data-x "2000" :data-y "0"
      (:div :class "row-fluid"
	    (:div :class "span12"
		  (str (step2))))
      (:div :class "row-fluid"
	    (:div :class "span6" :id "inputAreaContainer"
		  (:textarea :id "inputArea" :name "codeArea" ""))
	    (:div :class "span6" :id "reviewAreaContainer"
		  (:textarea :id "reviewArea" :name "reviewArea")))
      (:div :class "row-fluid"
	    (:button :class "eval" "Evaluar")
	    (:button :class "next" "Siguiente")
	    (:button :class "prev" "Anterior")))

(:div :class "step"
      :data-x "4000" :data-y "0"
      (:div :class "row-fluid"
	    (:div :class "span12"
		  (str (step3))))
      (:div :class "row-fluid"
	    (:div :class "span6" :id "inputAreaContainer"
		  (:textarea :id "inputArea" :name "codeArea" ""))
	    (:div :class "span6" :id "reviewAreaContainer"
		  (:textarea :id "reviewArea" :name "reviewArea")))
      (:div :class "row-fluid"
	    (:button :class "eval" "Evaluar")
	    (:button :class "next" "Siguiente")
	    (:button :class "prev" "Anterior")))

|#

(defun step1 ()
  "newLISP es un lenguaje interpretado, de prop&oacute;sito general, de la familia de los lenguajes Lisp. Trabaja especialmente bien para aplicaciones de inteligencia artificial, simulaci&oacute;n, procesamiento de lenguaje natural, big data, aprendizaje autom&aacute;tico y estad&iacute;stica. Debido a sus requerimientos bajos en recursos, newLISP es excelente para aplicaciones de sistemas embebidos. La mayor&iacute;a de las funciones que podr&iacute;as necesitar ya est&aacute;n incluidas en el lenguaje base. Esto incluye funciones de networking, procesamiento distribuido y multin&uacute;cleo, y estad&iacute;stica Bayesiana.")

(defun step2 ()
  "Como primer ejercicio, imprimiremos el cl&aacute;sico \"Hola Mundo!\". Escribe (println \"Hola Mundo!\") en la caja de texto de abajo y despu&eacute;s presiona la combinaci&oacute;n de teclas \"Ctrl+Enter\".")

(defun step3 ()
  "Como segundo ejercicio, imprimiremos el cl&aacute;sico \"Hola Mundo!\". Escribe (println \"Hola Mundo!\") en la caja de texto de abajo y despu&eacute;s presiona la combinaci&oacute;n de teclas \"Ctrl+Enter\".")



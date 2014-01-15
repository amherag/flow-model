(ql:quickload "drakma")


(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]"))))



(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]"))))

(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]"))))


(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[4,5,3,4,7,6,3,3,5,5,7]"))))


;;maximo con notacion quetz
(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[5,6,4,5,8,7,4,4,6,6,8]"))))



;;mejor
(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[3, 2, 0, 0, 5, 0, 7, 3, 5, 3, 6]"))))

[5, 6, 4, 5, 8, 7, 4, 4, 6, 6, 8]
[3, 2, 0, 0, 5, 0, 7, 3, 5, 3, 6]




;;(ql:quickload "cl-redis")
;;(ql:quickload "cl-json")
;;(redis:connect)
;;(redis:connect :host #(192 155 81 17) :port 6380)
;;(length (redis:red-keys "*"))
;;(redis:disconnect)
;;(map nil (lambda (k) (print (redis:red-get k))) (redis:red-keys "*"))

;;(defparameter *result* (apply #'redis:red-mget (redis:red-keys "*")))

(ql:quickload "yason")
(sort (mapcar (lambda (a b)
	  (list a
		(cl-ppcre:scan-to-strings "[0-9]+" (cl-ppcre:scan-to-strings "'id': u'pop:individual:[0-9]+" b)))

	  ) (mapcar (lambda (i)
	  (if i
	  (read-from-string i)
	  0))
	(mapcar (lambda (i)
	  (cl-ppcre:scan-to-strings "[0-9\\.]+" i)) (mapcar (lambda (i)
	  (cl-ppcre:scan-to-strings "u'currentFitness': ([0-9\\.]+)" i)) *result*)))
	    *result*) #'> :key (lambda (elt)
				 (car elt)))

mejor:

(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[1, 6, 4, 4, 1, 4, 2, 3, 2, 6, 4]"))))

;;mejor texto
"Diseñamos este carro único, con el fin de ser la mejor forma de moverte con tu familia. Por eso está fabricado con protecciones a los costados contra accidentes. Puede incluir un sistema antibloqueo de ruedas y bolsas de aire seguras. Tiene transmisión manual de 5 velocidades."

;;mejor
(redis:red-get "pop:individual:170")
[1, 6, 4, 4, 1, 4, 2, 3, 2, 6, 4]
u'currentFitness': 1.0
views:4

;;pops
(redis:red-get "pop:individual:32")
[3, 6, 2, 4, 7, 0, 2, 3, 2, 6, 4]
fitness: 0.6
views: 6

;;moms
(redis:red-get "pop:individual:79")
[1, 6, 4, 4, 1, 4, 1, 0, 5, 6, 6]
fitness: 1.0
views: 1

peor:

;;peor texto
"Creamos esta pieza de arte, para ser la mejor forma de viajar con tus amigos. Por eso está construido con protecciones laterales contra golpes. Puede incluir frenos antiderrapantes y bolsas de aire al frente. Compra seguro, compra inteligentemente."

(drakma:http-request "http://text.evospace.org/newtext/" :method :post :content-type "application/json" :content (json:encode-json-to-string '(("chrom" . "[2, 3, 1, 1, 2, 3, 4, 2, 6, 2, 0]"))))

(redis:red-get "pop:individual:127")
[2, 3, 1, 1, 2, 3, 4, 2, 6, 2, 0]
currentFitness: 0.16666666666666666
views: 8

(redis:red-get "pop:individual:108") ;;pops
[2, 3, 2, 2, 4, 5, 1, 0, 4, 6, 7]
currentFitness: 0.3333333333333333
views: 3

(redis:red-get "pop:individual:54") ;;moms
[5, 1, 3, 1, 2, 3, 4, 2, 6, 2, 0]
currentFitness: 0.3333333333333333
views: 5




*result*





(mapcar (lambda (i)
	  (cl-ppcre:scan-to-strings "u'currentFitness': ([0-9\\.]+)" i)) *result*)

*result*

(cl-ppcre:scan-to-strings "u'currentFitness': ([0-9\\.]+)" "{u'currentFitness': 0.7272727272727273, u'views': 10, u'papa': u'pop:individual:60', u'crossover': u'crossHorizontal:8', u'mutation': u'random', 'fitness': {u'556920701:1382342944558': 1, u'100001230812404:1382342071352': 1, u'1104275677:1382381604451': 1, u'DefaultContext': 0, u'1612401458:1382383678519': 1, u'100001230812404:1382342111822': 1, u'100001401828625:1382402038608': 1, u'100001230812404:1382341961680': 1}, u'mama': u'pop:individual:294', 'id': u'pop:individual:300', 'chromosome': [85, 9, 0, 1, 0, 0, 3, 1, 0, 1, 3, 0, 0, 1, 1]}")

(apply #'+ '(2 2))

"pop:individual:300" "pop:individual:220" "pop:individual:301"

(redis:red-get "pop:individual:300")


;;mis resultados

(defun data-to-json ()
  (mapcar (lambda (s)
	  (json:decode-json-from-string s))
	(mapcar (lambda (k) (cl-ppcre:regex-replace-all ": {} " (cl-ppcre:regex-replace-all "{([0-9]+):" (cl-ppcre:regex-replace-all "}, }" (cl-ppcre:regex-replace-all ", ([0-9]+):" (redis:red-get k) ", \"\\1\": ") "}}, ") "{\"\\1\":") ": {}, ")) (redis:red-keys "*"))))

(length (apply #'redis:red-mget (redis:red-keys "*")))

(defun data-to-json ()
  *data*)

(defun data-to-json ()
  (concatenate 'list *data* *data2*))

(mapcar (lambda (s)
	  (json:decode-json-from-string s))
	(mapcar (lambda (k) ) (redis:red-keys "*")))

(mapcar (lambda (r)
	  ) (cl-ppcre:regex-replace-all ": {} " (cl-ppcre:regex-replace-all "{([0-9]+):" (cl-ppcre:regex-replace-all "}, }" (cl-ppcre:regex-replace-all ", ([0-9]+):" (redis:red-get k) ", \"\\1\": ") "}}, ") "{\"\\1\":") ": {}, "))

(mapcar (lambda (obj)
	  (json:decode-json-from-string
	   (cl-ppcre:regex-replace-all ": {} " (cl-ppcre:regex-replace-all "{([0-9]+):" (cl-ppcre:regex-replace-all "}, }" (cl-ppcre:regex-replace-all ", ([0-9]+):" obj ", \"\\1\": ") "}}, ") "{\"\\1\":") ": {}, ")
	   )) *data2*)

'("Rene Marquez" "Quetzali Madera" "vigueras ortiz veronica esther"
 "braulio ballesteros" "Adriana Arias Lieras"
 "Jose Antonio Rafael Aburto Sanchez" "Jorge Perez Lomeli"
 "romero martinez lizbeth" "mario garcia valdez" "jose antonio salazar morin"
 "Diana Guadalupe Martinez Ramirez" "JONATHAN PEREZ" "Martha Ochoa"
 "M. del Carmen Ramirez Garcia" "Aurelio Meza Mendoza")

'("Amaury Hernandez" "fausto rodriguez"
 "David Salomon de la O Hidalgo" "Beatriz Lurdes Gonzalez Meza"
 "Coral Sanchez" "cinthia peraza ramirez"
 "MARIBEL GUERRERO LUIS")

(defun names ()
  (let ((names (remove-duplicates (mapcar (lambda (obj)
					    (cdr (assoc :user obj))) (data-to-json)) :test #'string=)))
    (values names (length names))))

(defun all-feeling ()
  (let (result)
    (dolist (obj (data-to-json) result)
      (if (assoc :mentalstate obj)
	  (push obj result)))))

(defun all-sliding ()
  (let (result)
    (dolist (obj (data-to-json) result)
      (if (assoc :timeintervals obj)
	  (push obj result)))))

(defun all-coding ()
  (let (result)
    (dolist (obj (data-to-json) result)
      (if (assoc :codesent obj)
	  (push obj result)))))

(defun feeling (user-number)
  (let ((result)
	(user (nth user-number (names))))
    (dolist (obj (all-feeling) result)
      (if (string= (cdr (assoc :user obj)) user)
	  (push obj result)))))

(defun sliding (user-number)
  (let ((result)
	(user (nth user-number (names))))
    (dolist (obj (all-sliding) result)
      (if (string= (cdr (assoc :user obj)) user)
	  (push obj result)))))

(defun coding (user-number)
  (let ((result)
	(user (nth user-number (names))))
    (dolist (obj (all-coding) result)
      (if (string= (cdr (assoc :user obj)) user)
	  (push obj result)))))

(defun fis-data (user-number problem-number)
  (let ((tries (length
		(let (result)
		  (dolist (obj (coding user-number) result)
		    (if (string= (format nil "~a" problem-number) (cdr (assoc :activestep obj)))
			(push obj result))))))
	(keypresses (cdr (assoc :keypresses
				(find problem-number (sliding user-number)
				      :key (lambda (elt)
					     (cdr (assoc :activestep elt)))))))
	(slidetime (cdr (assoc :slidetime
			       (find problem-number (sliding user-number)
				     :key (lambda (elt)
					    (cdr (assoc :activestep elt)))))))
	(thinkingtime (cdr (assoc :thinkingtime
				  (find problem-number (sliding user-number)
					:key (lambda (elt)
					       (cdr (assoc :activestep elt)))))))
	(keythinkingtime (let* ((thinkingtime (cdr (assoc :thinkingtime
							  (find problem-number (sliding user-number)
								:key (lambda (elt)
								       (cdr (assoc :activestep elt)))))))
				(slidetime (cdr (assoc :slidetime
						       (find problem-number (sliding user-number)
							     :key (lambda (elt)
								    (cdr (assoc :activestep elt)))))))
				(keypresses (cdr (assoc :keypresses
							(find problem-number (sliding user-number)
							      :key (lambda (elt)
								     (cdr (assoc :activestep elt)))))))
				(writingtime (- slidetime thinkingtime))
				(avgkeytime (float (/ writingtime keypresses)))
				(result 0)
				(no 0))
			   (dolist (time (cdr (assoc :timeintervals
						     (find problem-number (sliding user-number)
							   :key (lambda (elt)
								  (cdr (assoc :activestep elt)))))) (float (/ result no)))
			     (when (> (cdr (assoc :milliseconds (cdr time))) avgkeytime)
			       (incf result (cdr (assoc :milliseconds (cdr time))))
			       (incf no)))))
	(mentalstate (cdr (assoc :mentalstate (find (1- problem-number) (feeling user-number)
						    :key (lambda (elt) (cdr (assoc :activestep elt)))))))
	(difficulty (cdr (assoc :difficulty (find (1- problem-number) (feeling user-number)
						    :key (lambda (elt) (cdr (assoc :activestep elt))))))))
    `((:tries . ,tries) (:keypresses . ,keypresses)
      (:slidetime . ,slidetime) (:thinkingtime . ,thinkingtime)
      (:keythinkingtime . ,keythinkingtime) (:mentalstate . ,mentalstate)
      (:difficulty . ,difficulty))))

(sliding 1)
(feeling 1)

(with-open-file (s "~/results.csv" :direction :output :if-exists :supersede)
  (format s "tries,keypresses,slidetime,thinkingtime,keythinkingtime,mentalstate,difficulty~%")
  (map nil (lambda (data)
	     (map nil (lambda (datum)
			(if (eq (car datum) :difficulty)
			    (progn
			      (when (or (string= (cdr datum) "tooeasy")
					(string= (cdr datum) "easy")
				    ;;(string= (cdr datum) "control")
					)
				(format s "easy,"))
			      (when (or (string= (cdr datum) "toohard")
					(string= (cdr datum) "hard"))
				(format s "hard,"))
			      (when (string= (cdr datum) "normal")
				(format s "normal,")))
			      (format s "~a," (cdr datum)))
			) data)
	     (format s "~%"))

       (list
	;;(fis-data 0 7)
	(fis-data 1 7)
	;;(fis-data 2 7)
	(fis-data 3 7)
	(fis-data 4 7)
	(fis-data 5 7)
	(fis-data 6 7)
	;;(fis-data 7 7)
	(fis-data 8 7)
	(fis-data 9 7)
	;;(fis-data 10 7)
	(fis-data 11 7)
	(fis-data 12 7)
	(fis-data 13 7)
	(fis-data 14 7)
	(fis-data 15 7)
	;;(fis-data 16 7)
	(fis-data 17 7)
	(fis-data 18 7)
	(fis-data 19 7)
	(fis-data 20 7)
	(fis-data 21 7)
	)

       #|(list
	(fis-data 0 2)
	(fis-data 0 3)
	(fis-data 1 2)
	(fis-data 1 3)
	(fis-data 1 4)
	(fis-data 1 5)
	(fis-data 1 6)
	(fis-data 1 7)
	(fis-data 3 2)
	(fis-data 3 3)
	(fis-data 3 4)
	(fis-data 3 5)
	(fis-data 3 6)
	(fis-data 3 7)
	(fis-data 4 2)
	(fis-data 4 3)
	(fis-data 4 4)
	(fis-data 4 5)
	(fis-data 4 6)
	(fis-data 4 7)
	(fis-data 5 2)
	(fis-data 5 3)
	(fis-data 5 4)
	(fis-data 5 5)
	(fis-data 5 6)
	(fis-data 5 7)
	(fis-data 6 2)
	(fis-data 6 3)
	(fis-data 6 4)
	(fis-data 6 5)
	(fis-data 6 6)
	(fis-data 6 7)
	(fis-data 7 2)
	(fis-data 7 3)
	(fis-data 7 4)
	(fis-data 8 2)
	(fis-data 8 3)
	(fis-data 8 4)
	(fis-data 8 5)
	(fis-data 8 6)
	(fis-data 8 7)
	(fis-data 9 2)
	(fis-data 9 3)
	(fis-data 9 4)
	(fis-data 9 5)
	(fis-data 9 6)
	(fis-data 9 7)
	(fis-data 10 2)
	(fis-data 10 3)
	(fis-data 11 2)
	(fis-data 11 3)
	(fis-data 11 4)
	(fis-data 11 5)
	(fis-data 11 6)
	(fis-data 11 7)
	(fis-data 12 2)
	(fis-data 12 3)
	(fis-data 12 4)
	(fis-data 12 5)
	(fis-data 12 6)
	(fis-data 12 7)
	(fis-data 13 2)
	(fis-data 13 3)
	(fis-data 13 4)
	(fis-data 13 5)
	(fis-data 13 6)
	(fis-data 13 7)
	(fis-data 14 2)
	(fis-data 14 3)
	(fis-data 14 4)
	(fis-data 14 5)
	(fis-data 14 6)
	(fis-data 14 7)
	(fis-data 15 2)
	(fis-data 15 3)
	(fis-data 15 4)
	(fis-data 15 5)
	(fis-data 15 6)
	(fis-data 15 7)
	(fis-data 17 2)
	(fis-data 17 3)
	(fis-data 17 4)
	(fis-data 17 5)
	(fis-data 17 6)
	(fis-data 17 7)
	(fis-data 18 2)
	(fis-data 18 3)
	(fis-data 18 4)
	(fis-data 18 5)
	(fis-data 18 6)
	(fis-data 18 7)
	(fis-data 19 2)
	(fis-data 19 3)
	(fis-data 19 4)
	(fis-data 19 5)
	(fis-data 19 6)
	(fis-data 19 7)
	(fis-data 20 2)
	(fis-data 20 3)
	(fis-data 20 4)
	(fis-data 20 5)
	(fis-data 20 6)
	(fis-data 20 7)
	(fis-data 21 2)
	(fis-data 21 3)
	(fis-data 21 4)
	(fis-data 21 5)
	(fis-data 21 7)
	)|#
       )
  )

;;otros datos



(defun problem-stats (problem-number)
  (list (fis-data 1 problem-number)
	(fis-data 4 problem-number)
	(fis-data 5 problem-number)
	(fis-data 6 problem-number)
	(fis-data 8 problem-number)
	(fis-data 9 problem-number)
	(fis-data 11 problem-number)
	(fis-data 12 problem-number)
	(fis-data 13 problem-number)
	(fis-data 14 problem-number)
	))

(fis-data 1 1)

(feeling 13)

(with-open-file (s "~/results.csv" :direction :output :if-exists :supersede)
  (format s "tries,keypresses,slidetime,thinkingtime,keythinkingtime,mentalstate,difficulty~%")
  
  (loop for i from 2 upto 7 do (map nil (lambda (data)
	     (map nil (lambda (datum)
			(if (eq (car datum) :mentalstate)
			    (if (or (string= (cdr datum) "flow")
				    ;;(string= (cdr datum) "arousal")
				    (string= (cdr datum) "control")
				    )
				(format s "flow,")
				(format s "noflow,"))
			    (format s "~a," (cdr datum)))
		  ) data)
	     (format s "~%")) (problem-stats i)))
  )

;;unchanged
(with-open-file (s "~/results.csv" :direction :output :if-exists :supersede)
  (format s "tries,keypresses,slidetime,thinkingtime,keythinkingtime,mentalstate,difficulty~%")
  
  (loop for i from 2 upto 7 do (map nil (lambda (data)
	     (map nil (lambda (datum)
			(format s "~a," (cdr datum))
		  ) data)
	     (format s "~%")) (problem-stats i)))
  )

(fis-data 1 2)
(fis-data 1 4)
(feeling 1)
448255
(- 449145 448255)
(- 492835 43690)

(let* ((thinkingtime (cdr (assoc :thinkingtime
				 (find 4 (sliding 13)
				       :key (lambda (elt)
					      (cdr (assoc :activestep elt)))))))
       (slidetime (cdr (assoc :slidetime
			      (find 4 (sliding 13)
				    :key (lambda (elt)
					   (cdr (assoc :activestep elt)))))))
       (keypresses (cdr (assoc :keypresses
			      (find 4 (sliding 13)
				    :key (lambda (elt)
					   (cdr (assoc :activestep elt)))))))
       (writingtime (- slidetime thinkingtime))
       (avgkeytime (float (/ writingtime keypresses)))
       (result 0)
       (no 0))
  (dolist (time (cdr (assoc :timeintervals
			    (find 4 (sliding 13)
				  :key (lambda (elt)
					 (cdr (assoc :activestep elt)))))) (float (/ result no)))
    (when (> (cdr (assoc :milliseconds (cdr time))) avgkeytime)
      (incf result (cdr (assoc :milliseconds (cdr time))))
      (incf no))))

(sliding 13)

(sliding 13)


(fis-data 13 6)
(fis-data 1 2)



(coding 13)
(coding 1)


numero de intentos
numero de caracteres escritos
tiempo total
tiempo en pensar
tiempo promedio entre keystrokes

(feeling 13)
(sliding 13)
(length (coding 5))
(length (coding 13))

(length (names))

5 contestaron todo
1 cuatro
1 nada
1 dos

(defun get)

(feeling "jose antonio salazar morin")
(feeling "Adriana Arias Lieras")
(feeling "Jorge Perez Lomeli")
(feeling "Aurelio Meza Mendoza")
(names)
(length (all-coding))

(length (all-sliding))

(length (all-feeling))

(mapcar (lambda (obj)
	  (if (assoc :mentalstate obj)
	      obj)) (data-to-json))



(names)

(length (remove-duplicates (mapcar (lambda (obj)
	  (cdr (assoc :user obj))) (data-to-json)) :test #'string=))

(mapcar (lambda (obj)
	  (cdr (assoc :user obj))) (data-to-json))

(redis:red-keys "*")

(json:decode-json-from-string (redis:red-get *key*))

(dotimes (x 157)
(json:decode-json-from-string
 (cl-ppcre:regex-replace-all ": {} " (cl-ppcre:regex-replace-all "{([0-9]+):" (cl-ppcre:regex-replace-all "}, }" (cl-ppcre:regex-replace-all ", ([0-9]+):" (redis:red-get
(nth
x (redis:red-keys "*"))) ", \"\\1\": ") "}}, ") "{\"\\1\":") ": {}, ")
))



(cl-ppcre:regex-replace-all "([0-9]+):" "hola 123: como 31 estas 512" "\"\\1 hola\"")
(cl-ppcre:regex-replace-all "}, }" "hola }, }" "hola")

hola como estas

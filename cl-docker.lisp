(ql:quickload "cl-json")
(ql:quickload "drakma")
(defpackage :docker (:use :cl)
	    (:export
	     create-container
	     run-container))
(in-package :docker)

(setf drakma:*text-content-types* (cons '("application" . "json") drakma:*text-content-types*))
(setf drakma:*text-content-types* (cons '("application" . "vnd.docker.raw-stream") drakma:*text-content-types*))

(defparameter *url* "http://131.0.0.2:5555"
  "No trailing slash at the end!")

;;
;;
;;                CONTAINERS
;;
;;

(defun get-containers (&optional (format "json"))
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/containers/~a?all=1" *url* format)
			:accept "application/json")))

(defun delete-container (container-id)
  (drakma:http-request (format nil "~a/containers/~a"
			       *url* container-id)
		       :method :delete
		       :accept "application/json"))

(defun run-container (&optional (command "date") (run-time 5) (auto-remove t))
  (let ((container-id (create-container :command command))
	(starting-time (get-universal-time)))
    (start-container container-id)
    (sleep 0.2)
    (prog1
	(do () (nil)
	  (if (running-container? container-id)
	      (sleep 1)
	      (return (string-trim '(#\Space #\Tab #\Newline #\Return)
				   (attach-container container-id))))
	  (when (> (- (get-universal-time) starting-time) run-time)
	    (kill-container container-id)
	    (return "Tu proceso tardó más de 5 segundos.")))
      (when auto-remove
	(delete-container container-id)))))

(defun create-container (&key (command '("date")) (image "ubuntu:latest")
       (memory 0) (tty t) (attach-stdin nil) (attach-stdout t)
       (attach-stderr nil) (open-stdin nil) (stdin-once nil) (exposed-ports nil))
  (let* ((result (handler-case (json:decode-json-from-string
				(drakma:http-request
				 (format nil "~a/containers/create" *url*)
				 :method :post
				 :content-type "application/json"
				 :content (json:encode-json-to-string
					   `(("Hostname" . "")
					     ("User" . "")
					     ("Memory" . ,memory)
					     ("MemorySwap" . 0)
					     ("CpuShares" . 1)
					     ("AttachStdin" . ,attach-stdin)
					     ("AttachStdout" . ,attach-stdout)
					     ("AttachStderr" . ,attach-stderr)
					     ("PortSpecs" . nil)
					     ("ExposedPorts" . ,(let ((ports (make-hash-table)))
								   (dolist (x exposed-ports)
								     (setf (gethash x ports) (make-hash-table)))
								   ports))
					     ("Privileged" . nil)
					     ("Tty" . ,tty)
					     ("OpenStdin" . ,open-stdin)
					     ("StdinOnce" . ,stdin-once)
					     ("Env" . nil)
					     ("Cmd" . ,command)
					     ("Dns" . nil)
					     ("Image" . ,image)
					     ("Volumes" . ())
					     ("VolumesFrom" . "")
					     ("WorkingDir" . "")))
				 ;;:parameters '(("name" . "testing"))
				 ))
		   (error (condition)
		     (values nil condition))))
	 (container-id (if result
			   (cdr (assoc :*ID result)))))
    container-id))

(defun running-container? (container-id)
  (cdr (assoc :*running (cdr (assoc :*state (inspect-container container-id))))))

(defun attach-container (container-id &key (logs nil) (stream nil) (stdin nil) (stdout nil) (stderr nil))
  (let ((logs (if logs "true" "false"))
	(stream (if stream "true" "false"))
	(stdin (if stdin "true" "false"))
	(stdout (if stdout "true" "false"))
	(stderr (if stderr "true" "false")))
    (drakma:http-request (format nil "~a/containers/~a/attach?logs=~a&stream=~a&stdin=~a&stdout=~a&stderr=~a" *url* container-id logs stream stdin stdout stderr)
			 :method :post
			 :want-stream (if (string= stream "true") t nil)
			 :accept "application/vnd.docker.raw-stream")))

(defun start-container (container-id &key port-bindings)
  (let ((port-bindings (json:encode-json-to-string
			(let ((result (make-hash-table))
			      (tmp1 (make-hash-table)))
			  (dolist (x port-bindings) (let ((tmp2 (make-hash-table)))
						      (setf (gethash "HostPort" tmp2) (cdr x))
						      (setf (gethash (car x) tmp1) `#(,tmp2))))
			  (setf (gethash "PortBindings" result) tmp1)
			  result))))
    (drakma:http-request (format nil "~a/containers/~a/start" *url* container-id)
			 :method :post
			 :content-type "application/json"
			 :content port-bindings)))

(defun kill-container (container-id)
   (drakma:http-request (format nil "~a/containers/~a/kill" *url* container-id)
			:method :post))

(defun inspect-container (container-id)
  (json:decode-json-from-string
   (drakma:http-request
    (format nil "~a/containers/~a/json" *url* container-id)
    :accept "application/json")))

(defun commit-container (container-id repository tag)
  (json:decode-json-from-string
   (drakma:http-request
    (format nil "~a/commit?container=~a&repo=~a&tag=~a" *url* container-id repository tag)
    :method :post
    :accept "application/json")))

#|
(setf cont (create-container :command '("/usr/bin/newlisp" "-c" "-d" "4000")
			     :attach-stdin t :open-stdin t :exposed-ports '("4000/tcp")
			     :memory 0 :image "enjail/newlisp:10.3.4"))
(setf cont (create-container :command '() :image "tutum/ubuntu-precise:latest" :attach-stderr t))
;;(create-image "tutum/apache-php" "latest")
(inspect-container cont)
(attach-container cont :logs t :stdout t :stderr t)
(start-container cont :port-bindings '(("22/tcp" . "4000")))
(start-container cont :port-bindings '(("22/tcp")))
(start-container cont)
(start-container cont :port-bindings '(("4000/tcp" . "9000")))
(kill-container cont)
(delete-container cont)

(inspect-image "e7737f8200dc")
(get-containers)
;;(create-image "tutum/ubuntu-precise" "latest")


(commit-container cont "myrepo" "latest")

|#

;;
;;
;;                IMAGES
;;
;;

(defun get-images ()
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/images/json?all=1" *url*)
			:accept "application/json")))

(defun create-image (base-image tag)
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/images/create?fromImage=~a&tag=~a" *url* base-image tag)
			:method :post
			:accept "application/json")))

(defun file-image (image-id path url)
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/images/~a/insert?path=~a&url=~a" *url* image-id path url)
			:method :post
			:accept "application/json")))

(defun inspect-image (image-id)
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/images/~a/json" *url* image-id)
			:accept "application/json")))



;;(file-image "368fa21620c49594c305567d41058769826ca9e44dba2eadf3db9479d68a8cc2"
;;	    "\/coco.jpg" "http://www.independent.co.uk/incoming/article8465213.ece/BINARY/original/v2-cute-cat-picture.jpg")

;;(create-image "ubuntu" "latest")
;;(create-image "ubuntu" "quantal")

;;(get-images)



#|

(json:encode-json-to-string
 `(("Hostname" . "")
   ("User" . "")
   ("Memory" . 0)
   ("MemorySwap" . 0)
   ("CpuShares" . 1)
   ("AttachStdin" . nil)
   ("AttachStdout" . nil)
   ("AttachStderr" . nil)
   ("PortSpecs" . nil)
   ("ExposedPorts" ("4000/tcp" . ,(make-hash-table)))
   ("Privileged" . nil)
   ("Tty" . nil)
   ("WorkingDir" . "")))

(make-instance 'standard-object)

(setf port (make-hash-table))
(setf (gethash "HostPort" port) "4000")

(setf cont (create-container :command '("/usr/bin/newlisp" "-c" "-d" "4000")
			     :attach-stdin t :open-stdin t :exposed-ports `("4000/tcp" . ,port)))
(start-container cont :port-bindings '(("4000/tcp" . "4000")))
(start-container cont)
(inspect-container cont)
(kill-container cont)
(delete-container cont)

(setf s (attach-container cont :stdout t :logs t :stream t :stdin nil))

(with-open-stream (s (attach-container cont :stdout nil :logs nil :stream t :stdin t))
  (format s "(+ 10 10)
"))

(attach-container cont :stdout t :logs t :stream nil :stdin nil)
(with-open-stream (s (attach-container cont :stdout t :logs t :stream t :stdin nil))
  (read-line s)
  (read-line s))
(kill-container cont)
(delete-container cont)

|#

;;(create-container :command "5")
;;(inspect-container "a6de0d1d223a55c520b8d57d2fee5236c11ae5de52b8fcd3473b3a9db58ddd9b")


;;(inspect-container *container*)

;;(delete-container *container*)

;;(run-container "(+ 10 10)")

;;(time (dotimes (x 2)
;;  (print (run-container "(+ 10 30)"))))

;;(time (run-container (create-container :command "(dotimes (x 100000) x)" :tty t)))
;;(time (run-container (create-container :command "(dotimes (x 100000) x)" :tty t)))

(defun delete-image (image-id)
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/images/~a" *url* image-id)
			:method :delete
			:accept "application/json")))

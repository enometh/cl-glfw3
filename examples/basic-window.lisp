;;;; basic-window.lisp
;;;; OpenGL example code borrowed from cl-opengl
(in-package #:cl-glfw3-examples)

(export '(basic-window-example))

(def-key-callback quit-on-escape (window key scancode action mod-keys)
  (declare (ignore window scancode mod-keys))
  (when (and (eq key :escape) (eq action :press))
    (set-window-should-close)))

(defun render ()
  (gl:clear :color-buffer)
  (gl:with-pushed-matrix
    (gl:color 1 1 1)
    (gl:rect -25 -25 25 25)))

(defun set-viewport (width height)
  (gl:viewport 0 0 width height)
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho -50 50 -50 50 -1 1)
  (gl:matrix-mode :modelview)
  (gl:load-identity))

(def-window-size-callback update-viewport (window w h)
  (declare (ignore window))
  (set-viewport w h))

(defun basic-window-example ()
  ;; Graphics calls on OS X must occur in the main thread
  (with-body-in-main-thread ()
    (with-init-window (:title "Window test" :width 600 :height 400)
      (setf %gl:*gl-get-proc-address* #'get-proc-address)
      (set-key-callback 'quit-on-escape)
      (set-window-size-callback 'update-viewport)
      (gl:clear-color 0 0 0 0)
      (set-viewport 600 400)
      (loop until (window-should-close-p)
         do (render)
         do (swap-buffers)
         do (poll-events)))))

#+nil
(basic-window-example)

;; may have load this file again if system is loaded
#+nil
(with-init-window (:title "Window test" :width 600 :height 400
		   :context-version-major 1
		   :context-version-minor 2
		   :context-creation-api :egl-context-api ;; :native-context-api
		   )
  (setf %gl:*gl-get-proc-address* #'get-proc-address)
  (set-key-callback 'quit-on-escape)
  (set-window-size-callback 'update-viewport)
  (gl:clear-color 0 0 0 0)
  (set-viewport 600 400)
  (loop until (window-should-close-p)
        do (render)
        do (swap-buffers)
        do (poll-events)))


;;; ----------------------------------------------------------------------
;;;
;;; two windows
;;;

(defmacro with-threadsafe-init (&body body)
  "see WITH-INIT"
  `(progn
     (let ((prev-error-fun (set-error-callback 'cl-glfw3::default-error-fun)))
       (unless (cffi:null-pointer-p prev-error-fun)
	 (%glfw:set-error-callback prev-error-fun)))
     (with-body-in-main-thread (:blocking t) (initialize))
     (unwind-protect (progn ,@body)
       (with-body-in-main-thread (:blocking t)
	 (%glfw:terminate)))))

(defun basic-two-window-example ()
  (with-threadsafe-init
    (let (windows)
      (with-body-in-main-thread (:blocking t)
	(push (create-window :title "Window Test1" :width 600
			     :height 400 :visible t)
	      windows)
	(make-context-current nil))
      (with-body-in-main-thread (:blocking t)
	(push (create-window :title "Window Test2" :width 600
			     :height 400 :visible t)
	      windows)
	(make-context-current nil))
      (setf %gl:*gl-get-proc-address* #'get-proc-address)
      (dolist (window windows)
	(make-context-current window)
	(set-key-callback 'quit-on-escape window)
	(set-window-size-callback 'update-viewport window)
	(gl:clear-color 0 0 0 0)
	(set-viewport 600 400))

      (loop while windows
	    do (loop for window in windows
		     while window
		     do
		     (cond ((window-should-close-p window)
			    (with-body-in-main-thread (:blocking t)
			      (destroy-window window))
			    (setq windows (delete window windows
						  :test #'cffi:pointer-eq)))
			   (t (make-context-current window)
			      (render)
			      (swap-buffers window))))
	    do (poll-events)))))
#+nil
(basic-two-window-example)

#||
(user:getenv "WAYLAND_DISPLAY")
(user:setenv "WAYLAND_DISPLAY" "wayland-0")
(glfw:init-hint :platform :wayland)
(glfw:get-platform)
||#

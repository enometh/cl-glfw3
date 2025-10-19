;;;; events.lisp
;;;; This example shows events in the title bar.
(in-package #:cl-glfw3-examples)

(export '(events-example))

(defparameter *keys-pressed* nil)
(defparameter *buttons-pressed* nil)
(defparameter *window-size* nil)
(defparameter *pointer-position* nil)
(defparameter *mod-keys* nil)
(defparameter *scroll-callback* nil)


(defun update-window-title (window)
  (set-window-title (format nil "size ~A | keys ~A | buttons ~A | mouse ~A | mods ~A | scroll ~A "
                            *window-size*
                            *keys-pressed*
                            *buttons-pressed*
			    *pointer-position*
			    *mod-keys*
			    *scroll-callback*)
                    window))

(def-key-callback key-callback (window key scancode action mod-keys)
  (declare (ignore scancode))
  (setq *mod-keys* mod-keys)
  (format t "key-callback ~A ~A~%" action mod-keys)
  (when (and (eq key :escape) (eq action :press))
    (set-window-should-close))
  (if (eq action :press)
      (pushnew key *keys-pressed*)
      (deletef *keys-pressed* key))
  (update-window-title window))

(def-mouse-button-callback mouse-callback (window button action mod-keys)
  (setq *mod-keys* mod-keys)
  (format t "mouse-callback ~A ~A~%" action mod-keys)
  (if (eq action :press)
    (pushnew button *buttons-pressed*)
    (deletef *buttons-pressed* button))
  (update-window-title window))

(def-scroll-callback scroll-callback (window x y)
  (declare (ignore window))
  (format t "scroll-callback ~S~&"
	  (list x y
		(setq *scroll-callback*
		      (cond ((zerop x)
			     (cond ((zerop y)
				    (warn "impossible!"))
				   ((plusp y) :scroll-up)
				   (t :scroll-down)))
			    ((plusp x)
			     (cond ((zerop y) :scroll-left)
				   (t (warn "impossible!"))))
			    (t (cond ((zerop y) :scroll-right)
				     (t (warn "impossible!"))))))))
  (update-window-title window))

(def-window-size-callback window-size-callback (window w h)
  (setf *window-size* (list w h))
  (update-window-title window))

(glfw:def-cursor-pos-callback update-cursor-pos (window x y)
  (setf *pointer-position* (list x y))
  (update-window-title window))

(defun events-example ()
  ;; Graphics calls on OS X must occur in the main thread
  (with-body-in-main-thread ()
    (with-init-window (:title "" :width 800 :height 200)
      (set-key-callback 'key-callback)
      (set-mouse-button-callback 'mouse-callback)
      (set-window-size-callback 'window-size-callback)
      (set-scroll-callback 'scroll-callback)
      (set-cursor-position-callback 'update-cursor-pos)
      (setf *window-size* (get-window-size))
      (update-window-title *window*)
      ;;#+nil ;madhu 251019 - without render/swap-buffers window exits
      (loop until (window-should-close-p)
         do (progn (gl:clear :color-buffer)
		   (gl:with-pushed-matrix
		     (gl:color 1 1 1)
		     (gl:rect -25 -25 25 25)))
         do (swap-buffers)
         do (wait-events))
      #+nil
      (loop until (window-should-close-p) do (wait-events)))))


#+nil
(events-example)
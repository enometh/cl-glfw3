;;; -*- Mode: LISP; Package: :cl-user; BASE: 10; Syntax: ANSI-Common-Lisp; -*-
;;;
;;;   Time-stamp: <>
;;;   Touched: Sun Nov 02 07:30:55 2025 +0530 <enometh@net.meer>
;;;   Bugs-To: enometh@net.meer
;;;   Status: Experimental.  Do not redistribute
;;;   Copyright (C) 2025 Madhu.  All Rights Reserved.
;;;
;;;  worksheet for generating bindings with borodust-claw (actually claw-cxx)
;;;
(in-package "CL-USER")

#+nil
(load "~/cl/extern/claw-cxx/claw-cxx.system")
#+nil
(require 'claw-cxx/util)

#+nil
(user::wildset-lpn-translations "GLFW"  "/dev/shm/claw-cxx-glfw3/")

#+nil
(claw.util::claw-cxx-defsystems
 :claw-cxx-glfw3
 :source-pathname (translate-logical-pathname "GLFW:;")
 :binary-pathname (let ((*binary-directory-fasl-root*
			 (translate-logical-pathname "GLFW:fasl;")))
		    (binary-directory "")))


;;; ----------------------------------------------------------------------
;;;
;;;
;;;
#+nil
(progn
(require 'claw-cxx)
(unless (cffi:find-foreign-library  "libresect.so")
  (cffi:load-foreign-library "libresect.so")))

#+nil
(claw.wrapper:claw-cxx-defwrapper
 :claw-cxx-glfw3
 :package "CLAW-CXX-GLFW3"
 :base-path "GLFW:gen"
 :headers ( "GLFW/glfw3.h"))

#+nil
(claw.wrapper:defwrapper (:claw-cxx-glfw3
			  (:system nil)
                          (:base-path #p"GLFW:gen")
			  (:headers #p"GLFW/glfw3.h")
                          (:includes)
			  (:system-includes)
                          (:targets
                           ((:and :x86-64 :linux) "x86_64-pc-linux-gnu")
			   #+nil
                           ((:and :x86 :linux) "i686-pc-linux-gnu"))
                          (:include-definitions "^[gG][lL][fF][wW]"))
  :in-package "CLAW-CXX-GLFW3"
  :trim-enum-prefix nil
  :recognize-bitfields t
  :recognize-strings t
  :with-adapter nil #+nil (:dynamic :path "lib/adapter.c"))

#+nil
(claw.wrapper:generate-wrapper :claw-cxx-glfw3)

#||
(setq $wrapper-def (gethash :CLAW-CXX-GLFW3 claw.wrapper::*wrapper-registry*))
(multiple-value-setq ($opts-spec $config)
  (values (car $wrapper-def) (cdr $wrapper-def)))
(setq $opts (claw.wrapper::eval-opts :claw-cxx-glfw3 $opts-spec))

(let ((claw.wrapper::*always-generate* t))
  (setq $bindings-table (claw.wrapper::make-bindings-table
			 :claw-cxx-glfw3
			 $opts
			 $config)))

(hash-keys $bindings-table)
;; => ("x86_64-pc-linux-gnu")
(setq $bindings (gethash "x86_64-pc-linux-gnu" $bindings-table))

(with-open-file (out "/dev/shm/1.l" :direction :output :if-exists :supersede)
  (loop for binding in (claw.wrapper::bindings-definition $bindings)
	do (prin1 binding out)
	(fresh-line out)
	(terpri out)))

(setf
 (claw.wrapper::persistent-options-bindings-path
  (claw.wrapper::wrapper-options-persistent $opts))
 #p"/tmp/bindings/")

(let ((claw.wrapper::*always-generate* nil))
  (claw.wrapper::persist-bindings $opts $bindings-table))
||#

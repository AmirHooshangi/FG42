;; This library provides some basic means to create a new FG42 extensions
(require 'cl-lib)

;; Variables -----------------------------
(defvar activated-extensions ()
  "A list of all activated extensions.")

(defvar disabled-abilities (make-hash-table)
  "A hash of all the disabled abilities")

;; Structures -----------------------------
(cl-defstruct fg42-extension
  "Each FG42 extension should implement a copy of this structure."
  name
  (version nil)
  ;; Callbacks
  (on-initialize nil)
  (on-load))


;; Functions ------------------------------

(defun active-ability? (name)
  "Return t if ability was not in disabled-abilities."
  (if (gethash name disabled-abilities) nil t))

(defun disable (&rest abilities)
  "Add the given abilities to disabled-abilities hash"
  (dolist (abl abilities)
    (puthash abl t disabled-abilities)))

;; Macros ---------------------------------
(defmacro ability (name deps &rest body)
  "Define an ability with the given name.

*deps* should be a list of abilities with the defined ability dependens
to them.

*body* is a block of code which will run as the ability initializer code."
  (declare (doc-string 2) (indent 0))
  `(if (active-ability? (intern ,(symbol-name name)))
       (when (null (delq t (mapcar 'active-ability? (quote ,deps))))
         ,@body)))

(defmacro extension (name &rest args)
  "A simple DSL to define new fg42 extension."
  ;(declare (doc-string 1) (indent 1))
  `(setq ,name (apply 'make-fg42-extension :name ,(symbol-name name) (quote ,args))))

(defmacro with-ability (name &rest body)
  "Run the block of code if an ability with the given name was not disable."
  `(when (active-ability? (intern ,(symbol-name name)))
     ,@body))

(provide 'fg42/extension)

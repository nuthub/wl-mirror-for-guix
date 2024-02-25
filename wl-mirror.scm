;;; Copyright © 2024 Julian Flake <flake@uni-koblenz.de>

(define-module (wl-mirror)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (guix gexp)
  #:use-module (gnu packages base)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages freedesktop))

(define-public wlr-protocols
  (let ((revision "0")
	(commit "4264185db3b7e961e7f157e1cc4fd0ab75137568"))
    (package
      (name "wlr-protocols")
      (version (git-version "0.0" revision commit))
      (source (origin
		(method git-fetch)
		(uri (git-reference
		      (url "https://gitlab.freedesktop.org/wlroots/wlr-protocols.git")
		      (commit commit)))
		(sha256
		 (base32
		  "045jj3mbhi7p2qn59krz0vap0wd3i6zgwkvpl97idy702bnk9mv6"))))
      (build-system gnu-build-system)
      (arguments
       '(#:phases (modify-phases %standard-phases
		    (delete 'configure)
		    (add-before 'build 'set-prefix-in-makefile
		      (lambda* (#:key outputs #:allow-other-keys)
			(let ((out (assoc-ref outputs "out")))
			  (substitute* "Makefile"
			    (("PREFIX=.*") (string-append "PREFIX="out "\n")))))))))    
      (inputs
       (list wayland))
      (home-page "https://gitlab.freedesktop.org/wlroots/wlr-protocols")
      (synopsis "Wayland protocols designed for use in wlroots (and other compositors).")
      (description
       "Wayland protocols designed for use in wlroots (and other compositors).")
      ;; TODO unknown LICENSE
      (license expat))))


(define-public wl-mirror
  (package
    (name "wl-mirror")
    (version "0.16.1")
    (source (origin
              (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/Ferdi265/wl-mirror")
		    (commit "v0.16.1")))
	      (sha256
	       (base32
		"0464m60xsbpfwvsszrdkjsxfvrbkr71hp7phsz05cqyvjwf6cism"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags
      #~(list "-DFORCE_SYSTEM_WL_PROTOCOLS=ON"
	      (string-append "-DWL_PROTOCOL_DIR="
                             #$(this-package-input "wayland-protocols") "/share/wayland-protocols")
	      "-DFORCE_SYSTEM_WLR_PROTOCOLS=ON"
	      (string-append "-DWLR_PROTOCOL_DIR="
                             #$(this-package-input "wlr-protocols") "/share/wlr-protocols"))))
    (inputs
     (list pkg-config egl-wayland mesa wayland wayland-protocols wlr-protocols))
    (home-page "https://github.com/Ferdi265/wl-mirror")
    (synopsis "A simple Wayland output mirror client")
    (description
     "wl-mirror attempts to provide a solution to sway's lack of output mirroring by mirroring an output onto a client surface.")
    (license gpl3)))

wl-mirror

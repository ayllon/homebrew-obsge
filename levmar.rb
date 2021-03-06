class Levmar < Formula
  desc "Native ANSI C implementations of the Levenberg-Marquardt algorithm"
  homepage "http://www.ics.forth.gr/~lourakis/levmar/"
  url "https://src.fedoraproject.org/repo/pkgs/rpms/levmar/levmar-2.5.tgz/md5/7ca14d79eda6e985f8355b719ae47d35/levmar-2.5.tgz"
  sha256 "b70f6ac3eff30ec29150e217b137312cb84e85529815efea2c12e4eab74b9d75"
  depends_on "lapack"

  patch :DATA

  def install
    inreplace "Makefile", "-lf2c", ""

    system "make", "-f", "Makefile.so"
    system "make", "-f", "Makefile", "lmdemo"

    include.install "levmar.h"
    lib.install Dir["liblevmar.*"]
    prefix.install "lmdemo"
  end

  test do
    system "#{prefix}/lmdemo"
  end
end

__END__
--- a/Makefile.so	2009-12-04 22:26:14.000000000 +0100
+++ b/Makefile.so	2018-10-22 14:57:43.000000000 +0200
@@ -6,41 +6,56 @@
 # major & minor shared lib numbers
 MAJ=2
 MIN=2
-ODIR=sobj # where to place object files for shared lib
 CC=gcc
 CONFIGFLAGS=-ULINSOLVERS_RETAIN_MEMORY
 #ARCHFLAGS=-march=pentium4 # YOU MIGHT WANT TO UNCOMMENT THIS FOR P4
 CFLAGS=-fPIC $(CONFIGFLAGS) $(ARCHFLAGS) -O3 -funroll-loops -Wall #-pg
 LAPACKLIBS_PATH=/usr/local/lib # WHEN USING LAPACK, CHANGE THIS TO WHERE YOUR COMPILED LIBS ARE!
-LIBOBJS=$(ODIR)/lm.o $(ODIR)/Axb.o $(ODIR)/misc.o $(ODIR)/lmlec.o $(ODIR)/lmbc.o $(ODIR)/lmblec.o $(ODIR)/lmbleic.o
+LIBOBJS=lm.o Axb.o misc.o lmlec.o lmbc.o lmblec.o lmbleic.o
 LIBSRCS=lm.c Axb.c misc.c lmlec.c lmbc.c lmblec.c lmbleic.c
-LAPACKLIBS=-llapack -lblas -lf2c # comment this line if you are not using LAPACK.
-                                 # On systems with a FORTRAN (not f2c'ed) version of LAPACK, -lf2c is
-                                 # not necessary; on others, -lf2c is equivalent to -lF77 -lI77
+LAPACKLIBS=-llapack -lblas  # comment this line if you are not using LAPACK.
+                                 # On systems with a FORTRAN (not f2c'ed) version of LAPACK,  is
+                                 # not necessary; on others,  is equivalent to -lF77 -lI77
 
 LIBS=$(LAPACKLIBS)
 
-$(ODIR)/liblevmar.so.$(MAJ).$(MIN): $(LIBOBJS)
-	$(CC) -shared -Wl,-soname,liblevmar.so.$(MAJ) -o $(ODIR)/liblevmar.so.$(MAJ).$(MIN) $(LIBOBJS) #-llapack -lblas -lf2c
+UNAME_S := $(shell uname -s)
+ifeq ($(UNAME_S),Darwin)
+	TARGET=liblevmar.dylib
+else
+	TARGET=liblevmar.so
+	LDFLAGS+=-Wl,-soname,liblevmar.so.$(MAJ)
+endif
+
+$(TARGET): $(TARGET).$(MAJ)
+	ln -s $< $@
+
+$(TARGET).$(MAJ): $(TARGET).$(MAJ).$(MIN)
+	ln -s $< $@
+
+$(TARGET).$(MAJ).$(MIN): $(LIBOBJS)
+	$(CC) -shared $(LDFLAGS) -o $@ $(LIBOBJS) $(LIBS)
+
+all: $(TARGET)
 
 # implicit rule for generating *.o files in ODIR from *.c files
-$(ODIR)/%.o : %.c
+%.o : %.c
 	$(CC) $(CFLAGS) -c $< -o $@
 
 
-$(ODIR)/lm.o: lm.c lm_core.c levmar.h misc.h compiler.h
-$(ODIR)/Axb.o: Axb.c Axb_core.c levmar.h misc.h
-$(ODIR)/misc.o: misc.c misc_core.c levmar.h misc.h
-$(ODIR)/lmlec.o: lmlec.c lmlec_core.c levmar.h misc.h
-$(ODIR)/lmbc.o: lmbc.c lmbc_core.c levmar.h misc.h compiler.h
-$(ODIR)/lmblec.o: lmblec.c lmblec_core.c levmar.h misc.h
-$(ODIR)/lmbleic.o: lmbleic.c lmbleic_core.c levmar.h misc.h
+lm.o: lm.c lm_core.c levmar.h misc.h compiler.h
+Axb.o: Axb.c Axb_core.c levmar.h misc.h
+misc.o: misc.c misc_core.c levmar.h misc.h
+lmlec.o: lmlec.c lmlec_core.c levmar.h misc.h
+lmbc.o: lmbc.c lmbc_core.c levmar.h misc.h compiler.h
+lmblec.o: lmblec.c lmblec_core.c levmar.h misc.h
+lmbleic.o: lmbleic.c lmbleic_core.c levmar.h misc.h
 
 clean:
 	@rm -f $(LIBOBJS)
 
 cleanall: clean
-	@rm -f $(ODIR)/liblevmar.so.$(MAJ).$(MIN)
+	@rm -f $(TARGET)
 
 depend:
 	makedepend -f Makefile $(LIBSRCS)

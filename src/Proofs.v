(* src/Proofs.v *)
From Stdlib Require Import Arith Lia List.
Import ListNotations.

From Basics Require Import Basics.
(* Alternative if you don’t use the Module wrapper:
   Require Import Basics.
*)

Import Basics.

Lemma sum_singleton :
  forall n, sum [n] = n.
Proof.
  intro n. simpl. lia.
Qed.

Lemma sum_cons_ge :
  forall x xs, sum (x :: xs) >= x.
Proof.
  intros x xs. simpl. lia.
Qed.

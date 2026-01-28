(* Test.v — minimal Rocq / Coq sanity check *)

From Coq Require Import Arith Bool List.
Import ListNotations.

(* A simple inductive type *)
Inductive color : Type :=
| Red
| Green
| Blue.

(* A function over the inductive type *)
Definition is_primary (c : color) : bool :=
  match c with
  | Red => true
  | Green => true
  | Blue => true
  end.

(* A recursive function *)
Fixpoint sum (xs : list nat) : nat :=
  match xs with
  | [] => 0
  | x :: xs' => x + sum xs'
  end.

(* A simple lemma about sum *)
Lemma sum_app :
  forall xs ys,
    sum (xs ++ ys) = sum xs + sum ys.
Proof.
  induction xs as [| x xs IH]; intros ys.
  - simpl. reflexivity.
  - simpl. rewrite IH. lia.
Qed.

(* A trivial theorem to check tactics *)
Theorem sum_singleton :
  forall n, sum [n] = n.
Proof.
  intros n. simpl. lia.
Qed.

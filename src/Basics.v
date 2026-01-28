(* src/Basics.v *)
From Stdlib Require Import Arith Lia List.
Import ListNotations.

Module Basics.

Fixpoint sum (xs : list nat) : nat :=
  match xs with
  | [] => 0
  | x :: xs' => x + sum xs'
  end.

Lemma sum_app :
  forall xs ys, sum (xs ++ ys) = sum xs + sum ys.
Proof.
  induction xs as [|x xs IH]; intros ys.
  - simpl. lia.
  - simpl. rewrite IH. lia.
Qed.

End Basics.

module Definition.LogicalRelation.Substitution where

open import Definition.Untyped
open import Definition.LogicalRelation

open import Tools.Context

open import Data.Nat
open import Data.Product
open import Data.Unit

import Relation.Binary.PropositionalEquality as PE


mutual
  data ⊨⟨_⟩_ (l : TypeLevel) : Con Term → Set where
    ε : ⊨⟨ l ⟩ ε
    _∙_ : ∀ {Γ A} ([Γ] : ⊨⟨ l ⟩ Γ) → Γ ⊨⟨ l ⟩ A / [Γ]
        -- → (∀ {Δ σ} → Δ ⊨⟨ l ⟩ σ ∷ Γ / [Γ]
        --            → Σ (Δ ⊩⟨ l ⟩ subst σ A)
        --                (λ [A] → ∀ {σ'} → Δ ⊨⟨ l ⟩ σ ≡ σ' ∷ Γ / [Γ]
        --                       → Δ ⊩⟨ l ⟩ subst σ A ≡ subst σ' A / [A]))
                              → ⊨⟨ l ⟩ Γ ∙ A


  _⊨⟨_⟩_∷_/_ : (Δ : Con Term) (l : TypeLevel) (σ : Subst) (Γ : Con Term) ([Γ] : ⊨⟨ l ⟩ Γ) → Set
  Δ ⊨⟨ l ⟩ σ ∷ .ε / ε = ⊤
  Δ ⊨⟨ l ⟩ σ ∷ .(Γ ∙ A) / (_∙_ {Γ} {A} [Γ] x) =
    Δ ⊨⟨ l ⟩ (\ x → σ (suc x)) ∷ Γ / [Γ] × -- (\ x → σ (suc x)) = tail σ
    (∃ λ [A] → Δ ⊩⟨ l ⟩ substVar σ 0 ∷ subst σ A / [A]) -- substVar σ 0 = head σ

  _⊨⟨_⟩_≡_∷_/_ : (Δ : Con Term) (l : TypeLevel) (σ σ' : Subst) (Γ : Con Term) ([Γ] : ⊨⟨ l ⟩ Γ) → Set
  Δ ⊨⟨ l ⟩ σ ≡ σ' ∷ .ε / ε = ⊤
  Δ ⊨⟨ l ⟩ σ ≡ σ' ∷ .(Γ ∙ A) / (_∙_ {Γ} {A} [Γ] x) =
    Δ ⊨⟨ l ⟩ (\ x → σ (suc x)) ≡ (\ x → σ' (suc x)) ∷ Γ / [Γ] ×
    (∃ λ [A] → Δ ⊩⟨ l ⟩ substVar σ 0 ≡ substVar σ' 0 ∷ subst σ A / [A])


  _⊨⟨_⟩_/_ : (Γ : Con Term) (l : TypeLevel) (A : Term) → ⊨⟨ l ⟩ Γ -> Set
  Γ ⊨⟨ l ⟩ A / [Γ] = (∀ {Δ σ} → Δ ⊨⟨ l ⟩ σ ∷ Γ / [Γ]
                   → Σ (Δ ⊩⟨ l ⟩ subst σ A)
                       (λ [A] → ∀ {σ'} → Δ ⊨⟨ l ⟩ σ ≡ σ' ∷ Γ / [Γ]
                              → Δ ⊩⟨ l ⟩ subst σ A ≡ subst σ' A / [A]))

_⊨⟨_⟩t_∷_/_ : (Γ : Con Term) (l : TypeLevel) (t A : Term) → ⊨⟨ l ⟩ Γ -> Set
Γ ⊨⟨ l ⟩t t ∷ A / [Γ] = Σ (Γ ⊨⟨ l ⟩ A / [Γ]) \ [A] →
        ∀ {Δ σ} → ([σ] : Δ ⊨⟨ l ⟩ σ ∷ Γ / [Γ]) → Σ (Δ ⊩⟨ l ⟩ subst σ t ∷ subst σ A / proj₁ ([A] [σ]))
                           (λ [t] → ∀ {σ'} → Δ ⊨⟨ l ⟩ σ ≡ σ' ∷ Γ / [Γ]
                              → Δ ⊩⟨ l ⟩ subst σ t ≡ subst σ' t ∷ subst σ A / proj₁ ([A] [σ]))

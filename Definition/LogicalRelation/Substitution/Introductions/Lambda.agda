{-# OPTIONS --without-K --safe #-}

open import Definition.Typed.EqualityRelation

module Definition.LogicalRelation.Substitution.Introductions.Lambda (M : Set) {{eqrel : EqRelSet M}} where
open EqRelSet {{...}}

open import Definition.Untyped M as U hiding (wk; _∷_)
open import Definition.Untyped.Properties M
open import Definition.Typed M
open import Definition.Typed.Properties M
open import Definition.Typed.Weakening M as T hiding (wk; wkTerm; wkEqTerm)
open import Definition.Typed.RedSteps M
open import Definition.LogicalRelation M
open import Definition.LogicalRelation.ShapeView M
open import Definition.LogicalRelation.Irrelevance M
open import Definition.LogicalRelation.Weakening M
open import Definition.LogicalRelation.Properties M
open import Definition.LogicalRelation.Application M
open import Definition.LogicalRelation.Substitution M
open import Definition.LogicalRelation.Substitution.Properties M
open import Definition.LogicalRelation.Substitution.Introductions.Pi M

open import Tools.Fin
open import Tools.Nat
open import Tools.Product
import Tools.PropositionalEquality as PE

private
  variable
    m n : Nat
    Γ : Con Term n
    Δ : Con Term m
    σ : Subst m n
    p q : M

-- Valid lambda term construction.
lamᵛ : ∀ {F G t l}
       ([Γ] : ⊩ᵛ Γ)
       ([F] : Γ ⊩ᵛ⟨ l ⟩ F / [Γ])
       ([G] : Γ ∙ F ⊩ᵛ⟨ l ⟩ G / [Γ] ∙ [F])
       ([t] : Γ ∙ F ⊩ᵛ⟨ l ⟩ t ∷ G / [Γ] ∙ [F] / [G])
     → Γ ⊩ᵛ⟨ l ⟩ lam p t ∷ Π p , q ▷ F ▹ G / [Γ] / Πᵛ {F = F} {G} [Γ] [F] [G]
lamᵛ {Γ = Γ} {p = p} {q = q} {F = F} {G} {t} {l} [Γ] [F] [G] [t] {k} {Δ = Δ} {σ = σ} ⊢Δ [σ] =
  let ⊢F = escape (proj₁ ([F] ⊢Δ [σ]))
      [liftσ] = liftSubstS {F = F} [Γ] ⊢Δ [F] [σ]
      [ΠFG] = Πᵛ {F = F} {G} [Γ] [F] [G]
      _ , Bᵣ F′ G′ D′ ⊢F′ ⊢G′ A≡A′ [F]′ [G]′ G-ext =
        extractMaybeEmb (Π-elim (proj₁ ([ΠFG] ⊢Δ [σ])))
      lamt : ∀ {Δ σ} (⊢Δ : ⊢ Δ) ([σ] : Δ ⊩ˢ σ ∷ Γ / [Γ] / ⊢Δ)
           → Δ ⊩⟨ l ⟩ subst σ (lam p t) ∷ subst σ (Π p , q ▷ F ▹ G) / proj₁ ([ΠFG] ⊢Δ [σ])
      lamt {Δ} {σ} ⊢Δ [σ] =
        let [liftσ] = liftSubstS {F = F} [Γ] ⊢Δ [F] [σ]
            [σF] = proj₁ ([F] ⊢Δ [σ])
            ⊢F = escape [σF]
            ⊢wk1F = T.wk (step id) (⊢Δ ∙ ⊢F) ⊢F
            [σG] = proj₁ ([G] (⊢Δ ∙ ⊢F) [liftσ])
            ⊢G = escape [σG]
            [σt] = proj₁ ([t] (⊢Δ ∙ ⊢F) [liftσ])
            ⊢t = escapeTerm [σG] [σt]
            wk1t[0] = irrelevanceTerm″
                        PE.refl
                        (PE.sym (wkSingleSubstId (subst (liftSubst σ) t)))
                        [σG] [σG] [σt]
            β-red′ = PE.subst (λ x → _ ⊢ _ ⇒ _ ∷ x)
                              (wkSingleSubstId (subst (liftSubst σ) G))
                              (β-red ⊢wk1F (T.wkTerm (lift (step id))
                                                     (⊢Δ ∙ ⊢F ∙ ⊢wk1F) ⊢t)
                                                     (var (⊢Δ ∙ ⊢F) here) PE.refl)
            _ , Bᵣ F′ G′ D′ ⊢F′ ⊢G′ A≡A′ [F]′ [G]′ G-ext =
              extractMaybeEmb (Π-elim (proj₁ ([ΠFG] ⊢Δ [σ])))
        in  Πₜ (lam p (subst (liftSubst σ) t)) (idRedTerm:*: (lamⱼ ⊢F ⊢t)) lamₙ
               (≅-η-eq ⊢F (lamⱼ ⊢F ⊢t) (lamⱼ ⊢F ⊢t) lamₙ lamₙ
                       (escapeTermEq [σG]
                         (reflEqTerm [σG]
                           (proj₁ (redSubstTerm {p = p} β-red′ [σG] wk1t[0])))))
               (λ {_} {_} {Δ₁} {a} {b} ρ ⊢Δ₁ [a] [b] [a≡b] →
                  let [ρσ] = wkSubstS [Γ] ⊢Δ ⊢Δ₁ ρ [σ]
                      [a]′ = irrelevanceTerm′ (wk-subst F) ([F]′ ρ ⊢Δ₁)
                                              (proj₁ ([F] ⊢Δ₁ [ρσ])) [a]
                      [b]′ = irrelevanceTerm′ (wk-subst F) ([F]′ ρ ⊢Δ₁)
                                              (proj₁ ([F] ⊢Δ₁ [ρσ])) [b]
                      [a≡b]′ = irrelevanceEqTerm′ (wk-subst F) ([F]′ ρ ⊢Δ₁)
                                                  (proj₁ ([F] ⊢Δ₁ [ρσ])) [a≡b]
                      ⊢F₁′ = escape (proj₁ ([F] ⊢Δ₁ [ρσ]))
                      ⊢F₁ = escape ([F]′ ρ ⊢Δ₁)
                      [G]₁ = proj₁ ([G] (⊢Δ₁ ∙ ⊢F₁′)
                                        (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ]))
                      [G]₁′ = irrelevanceΓ′
                                (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                                (PE.sym (wk-subst-lift G)) [G]₁
                      [t]′ = irrelevanceTermΓ″
                               (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                               (PE.sym (wk-subst-lift G))
                               (PE.sym (wk-subst-lift t))
                               [G]₁ [G]₁′
                               (proj₁ ([t] (⊢Δ₁ ∙ ⊢F₁′)
                                           (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ])))
                      ⊢a = escapeTerm ([F]′ ρ ⊢Δ₁) [a]
                      ⊢b = escapeTerm ([F]′ ρ ⊢Δ₁) [b]
                      ⊢t = escapeTerm [G]₁′ [t]′
                      G[a]′ = proj₁ ([G] ⊢Δ₁ ([ρσ] , [a]′))
                      G[a] = [G]′ ρ ⊢Δ₁ [a]
                      t[a] = irrelevanceTerm″
                               (PE.sym (singleSubstWkComp a σ G))
                               (PE.sym (singleSubstWkComp a σ t))
                               G[a]′ G[a]
                               (proj₁ ([t] ⊢Δ₁ ([ρσ] , [a]′)))
                      G[b]′ = proj₁ ([G] ⊢Δ₁ ([ρσ] , [b]′))
                      G[b] = [G]′ ρ ⊢Δ₁ [b]
                      t[b] = irrelevanceTerm″
                               (PE.sym (singleSubstWkComp b σ G))
                               (PE.sym (singleSubstWkComp b σ t))
                               G[b]′ G[b]
                               (proj₁ ([t] ⊢Δ₁ ([ρσ] , [b]′)))
                      lamt∘a≡t[a] = proj₂ (redSubstTerm {p = p} (β-red ⊢F₁ ⊢t ⊢a PE.refl) G[a] t[a])
                      G[a]≡G[b] = G-ext ρ ⊢Δ₁ [a] [b] [a≡b]
                      t[a]≡t[b] = irrelevanceEqTerm″
                                    (PE.sym (singleSubstWkComp a σ t))
                                    (PE.sym (singleSubstWkComp b σ t))
                                    (PE.sym (singleSubstWkComp a σ G))
                                    G[a]′ G[a]
                                    (proj₂ ([t] ⊢Δ₁ ([ρσ] , [a]′)) ([ρσ] , [b]′)
                                                (reflSubst [Γ] ⊢Δ₁ [ρσ] , [a≡b]′))
                      t[b]≡lamt∘b =
                        convEqTerm₂ G[a] G[b] G[a]≡G[b]
                          (symEqTerm G[b] (proj₂ (redSubstTerm {p = p} (β-red ⊢F₁ ⊢t ⊢b PE.refl)
                                                               G[b] t[b])))
                  in  transEqTerm G[a] lamt∘a≡t[a]
                             (transEqTerm G[a] t[a]≡t[b] t[b]≡lamt∘b))
               (λ {_} {_} {Δ₁} {a} ρ ⊢Δ₁ [a] →
                  let [ρσ] = wkSubstS [Γ] ⊢Δ ⊢Δ₁ ρ [σ]
                      [a]′ = irrelevanceTerm′ (wk-subst F) ([F]′ ρ ⊢Δ₁)
                                              (proj₁ ([F] ⊢Δ₁ [ρσ])) [a]
                      ⊢F₁′ = escape (proj₁ ([F] ⊢Δ₁ [ρσ]))
                      ⊢F₁ = escape ([F]′ ρ ⊢Δ₁)
                      [G]₁ = proj₁ ([G] (⊢Δ₁ ∙ ⊢F₁′)
                                        (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ]))
                      [G]₁′ = irrelevanceΓ′
                                (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                                (PE.sym (wk-subst-lift G)) [G]₁
                      [t]′ = irrelevanceTermΓ″
                               (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                               (PE.sym (wk-subst-lift G))
                               (PE.sym (wk-subst-lift t))
                               [G]₁ [G]₁′
                               (proj₁ ([t] (⊢Δ₁ ∙ ⊢F₁′)
                                           (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ])))
                      ⊢a = escapeTerm ([F]′ ρ ⊢Δ₁) [a]
                      ⊢t = escapeTerm [G]₁′ [t]′
                      G[a]′ = proj₁ ([G] ⊢Δ₁ ([ρσ] , [a]′))
                      G[a] = [G]′ ρ ⊢Δ₁ [a]
                      t[a] = irrelevanceTerm″ (PE.sym (singleSubstWkComp a σ G))
                                               (PE.sym (singleSubstWkComp a σ t))
                                               G[a]′ G[a]
                                               (proj₁ ([t] ⊢Δ₁ ([ρσ] , [a]′)))
                  in  proj₁ (redSubstTerm {p = p} (β-red ⊢F₁ ⊢t ⊢a PE.refl) G[a] t[a]))
  in  lamt ⊢Δ [σ]
  ,   (λ {σ′} [σ′] [σ≡σ′] →
         let [liftσ′] = liftSubstS {F = F} [Γ] ⊢Δ [F] [σ′]
             _ , Bᵣ F″ G″ D″ ⊢F″ ⊢G″ A≡A″ [F]″ [G]″ G-ext′ =
               extractMaybeEmb (Π-elim (proj₁ ([ΠFG] ⊢Δ [σ′])))
             ⊢F′ = escape (proj₁ ([F] ⊢Δ [σ′]))
             [G]₁ = proj₁ ([G] (⊢Δ ∙ ⊢F) [liftσ])
             [G]₁′ = proj₁ ([G] (⊢Δ ∙ ⊢F′) [liftσ′])
             [σΠFG≡σ′ΠFG] = proj₂ ([ΠFG] ⊢Δ [σ]) [σ′] [σ≡σ′]
             ⊢t = escapeTerm [G]₁ (proj₁ ([t] (⊢Δ ∙ ⊢F) [liftσ]))
             ⊢t′ = escapeTerm [G]₁′ (proj₁ ([t] (⊢Δ ∙ ⊢F′) [liftσ′]))
             neuVar = neuTerm ([F]′ (step id) (⊢Δ ∙ ⊢F))
                              (var x0) (var (⊢Δ ∙ ⊢F) here)
                              (~-var (var (⊢Δ ∙ ⊢F) here))
             σlamt∘a≡σ′lamt∘a : ∀ {ℓ} {ρ : Wk ℓ k} {Δ₁ a} → ([ρ] : ρ ∷ Δ₁ ⊆ Δ) (⊢Δ₁ : ⊢ Δ₁)
                 → ([a] : Δ₁ ⊩⟨ l ⟩ a ∷ U.wk ρ (subst σ F) / [F]′ [ρ] ⊢Δ₁)
                 → Δ₁ ⊩⟨ l ⟩ U.wk ρ (subst σ (lam p t)) ∘ p ▷ a
                           ≡ U.wk ρ (subst σ′ (lam p t)) ∘ p ▷ a
                           ∷ U.wk (lift ρ) (subst (liftSubst σ) G) [ a ]
                           / [G]′ [ρ] ⊢Δ₁ [a]
             σlamt∘a≡σ′lamt∘a {_} {_} {Δ₁} {a} ρ ⊢Δ₁ [a] =
                let [ρσ] = wkSubstS [Γ] ⊢Δ ⊢Δ₁ ρ [σ]
                    [ρσ′] = wkSubstS [Γ] ⊢Δ ⊢Δ₁ ρ [σ′]
                    [ρσ≡ρσ′] = wkSubstSEq [Γ] ⊢Δ ⊢Δ₁ ρ [σ] [σ≡σ′]
                    ⊢F₁′ = escape (proj₁ ([F] ⊢Δ₁ [ρσ]))
                    ⊢F₁ = escape ([F]′ ρ ⊢Δ₁)
                    ⊢F₂′ = escape (proj₁ ([F] ⊢Δ₁ [ρσ′]))
                    ⊢F₂ = escape ([F]″ ρ ⊢Δ₁)
                    [σF≡σ′F] = proj₂ ([F] ⊢Δ₁ [ρσ]) [ρσ′] [ρσ≡ρσ′]
                    [a]′ = irrelevanceTerm′ (wk-subst F) ([F]′ ρ ⊢Δ₁)
                                            (proj₁ ([F] ⊢Δ₁ [ρσ])) [a]
                    [a]″ = convTerm₁ (proj₁ ([F] ⊢Δ₁ [ρσ]))
                                      (proj₁ ([F] ⊢Δ₁ [ρσ′]))
                                      [σF≡σ′F] [a]′
                    ⊢a = escapeTerm ([F]′ ρ ⊢Δ₁) [a]
                    ⊢a′ = escapeTerm ([F]″ ρ ⊢Δ₁)
                            (irrelevanceTerm′ (PE.sym (wk-subst F))
                                              (proj₁ ([F] ⊢Δ₁ [ρσ′]))
                                              ([F]″ ρ ⊢Δ₁)
                                              [a]″)
                    G[a]′ = proj₁ ([G] ⊢Δ₁ ([ρσ] , [a]′))
                    G[a]₁′ = proj₁ ([G] ⊢Δ₁ ([ρσ′] , [a]″))
                    G[a] = [G]′ ρ ⊢Δ₁ [a]
                    G[a]″ = [G]″ ρ ⊢Δ₁
                                   (irrelevanceTerm′ (PE.sym (wk-subst F))
                                                     (proj₁ ([F] ⊢Δ₁ [ρσ′]))
                                                     ([F]″ ρ ⊢Δ₁)
                                                     [a]″)
                    [σG[a]≡σ′G[a]] = irrelevanceEq″
                                       (PE.sym (singleSubstWkComp a σ G))
                                       (PE.sym (singleSubstWkComp a σ′ G))
                                       G[a]′ G[a]
                                       (proj₂ ([G] ⊢Δ₁ ([ρσ] , [a]′))
                                              ([ρσ′] , [a]″)
                                              (consSubstSEq {t = a} {A = F}
                                                [Γ] ⊢Δ₁ [ρσ] [ρσ≡ρσ′] [F] [a]′))
                    [G]₁ = proj₁ ([G] (⊢Δ₁ ∙ ⊢F₁′)
                                      (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ]))
                    [G]₁′ = irrelevanceΓ′
                              (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                              (PE.sym (wk-subst-lift G)) [G]₁
                    [G]₂ = proj₁ ([G] (⊢Δ₁ ∙ ⊢F₂′)
                                      (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ′]))
                    [G]₂′ = irrelevanceΓ′
                              (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                              (PE.sym (wk-subst-lift G)) [G]₂
                    [t]′ = irrelevanceTermΓ″
                             (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                             (PE.sym (wk-subst-lift G)) (PE.sym (wk-subst-lift t))
                             [G]₁ [G]₁′
                             (proj₁ ([t] (⊢Δ₁ ∙ ⊢F₁′)
                                         (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ])))
                    [t]″ = irrelevanceTermΓ″
                              (PE.cong (λ x → _ ∙ x) (PE.sym (wk-subst F)))
                              (PE.sym (wk-subst-lift G)) (PE.sym (wk-subst-lift t))
                              [G]₂ [G]₂′
                              (proj₁ ([t] (⊢Δ₁ ∙ ⊢F₂′)
                                          (liftSubstS {F = F} [Γ] ⊢Δ₁ [F] [ρσ′])))
                    ⊢t = escapeTerm [G]₁′ [t]′
                    ⊢t′ = escapeTerm [G]₂′ [t]″
                    t[a] = irrelevanceTerm″
                             (PE.sym (singleSubstWkComp a σ G))
                             (PE.sym (singleSubstWkComp a σ t)) G[a]′ G[a]
                             (proj₁ ([t] ⊢Δ₁ ([ρσ] , [a]′)))
                    t[a]′ = irrelevanceTerm″
                              (PE.sym (singleSubstWkComp a σ′ G))
                              (PE.sym (singleSubstWkComp a σ′ t))
                              G[a]₁′ G[a]″
                              (proj₁ ([t] ⊢Δ₁ ([ρσ′] , [a]″)))
                    [σlamt∘a≡σt[a]] = proj₂ (redSubstTerm {p = p} (β-red ⊢F₁ ⊢t ⊢a PE.refl)
                                                          G[a] t[a])
                    [σ′t[a]≡σ′lamt∘a] =
                      convEqTerm₂ G[a] G[a]″ [σG[a]≡σ′G[a]]
                        (symEqTerm G[a]″
                           (proj₂ (redSubstTerm {p = p} (β-red ⊢F₂ ⊢t′ ⊢a′ PE.refl)
                                                G[a]″ t[a]′)))
                    [σt[a]≡σ′t[a]] = irrelevanceEqTerm″
                                       (PE.sym (singleSubstWkComp a σ t))
                                       (PE.sym (singleSubstWkComp a σ′ t))
                                       (PE.sym (singleSubstWkComp a σ G))
                                       G[a]′ G[a]
                                       (proj₂ ([t] ⊢Δ₁ ([ρσ] , [a]′))
                                              ([ρσ′] , [a]″)
                                              (consSubstSEq {t = a} {A = F}
                                                [Γ] ⊢Δ₁ [ρσ] [ρσ≡ρσ′] [F] [a]′))
                in  transEqTerm G[a] [σlamt∘a≡σt[a]]
                                (transEqTerm G[a] [σt[a]≡σ′t[a]]
                                             [σ′t[a]≡σ′lamt∘a])
         in  Πₜ₌ (lam p (subst (liftSubst σ) t)) (lam p (subst (liftSubst σ′) t))
                 (idRedTerm:*: (lamⱼ ⊢F ⊢t))
                 (idRedTerm:*: (conv (lamⱼ ⊢F′ ⊢t′)
                                     (sym (≅-eq (escapeEq (proj₁ ([ΠFG] ⊢Δ [σ]))
                                                              [σΠFG≡σ′ΠFG])))))
                 lamₙ lamₙ
                 (≅-η-eq ⊢F (lamⱼ ⊢F ⊢t)
                      (conv (lamⱼ ⊢F′ ⊢t′)
                            (sym (≅-eq (escapeEq (proj₁ ([ΠFG] ⊢Δ [σ]))
                                              [σΠFG≡σ′ΠFG]))))
                      lamₙ lamₙ
                      (escapeTermEq
                        (proj₁ ([G] (⊢Δ ∙ ⊢F) [liftσ]))
                        (irrelevanceEqTerm′
                          (idWkLiftSubstLemma σ G)
                          ([G]′ (step id) (⊢Δ ∙ ⊢F) neuVar)
                          (proj₁ ([G] (⊢Δ ∙ ⊢F) [liftσ]))
                          (σlamt∘a≡σ′lamt∘a (step id) (⊢Δ ∙ ⊢F) neuVar))))
                  (lamt ⊢Δ [σ])
                  (convTerm₂ (proj₁ ([ΠFG] ⊢Δ [σ]))
                             (proj₁ ([ΠFG] ⊢Δ [σ′]))
                             [σΠFG≡σ′ΠFG]
                             (lamt ⊢Δ [σ′]))
                      σlamt∘a≡σ′lamt∘a)


-- Reducibility of η-equality under a valid substitution.
η-eqEqTerm : ∀ {m′ n′} {σ : Subst m′ n′} {Γ Δ f g F G l}
             ([Γ] : ⊩ᵛ Γ)
             ([F] : Γ ⊩ᵛ⟨ l ⟩ F / [Γ])
             ([G] : Γ ∙ F ⊩ᵛ⟨ l ⟩ G / [Γ] ∙ [F])
           → let [ΠFG] = Πᵛ {F = F} {G} [Γ] [F] [G] in
             Γ ∙ F ⊩ᵛ⟨ l ⟩ wk1 f ∘ p ▷ var x0 ≡ wk1 g ∘ p ▷ var x0 ∷ G
                          / [Γ] ∙ [F] / [G]
           → (⊢Δ   : ⊢ Δ)
             ([σ]  : Δ ⊩ˢ σ ∷ Γ / [Γ] / ⊢Δ)
           → Δ ⊩⟨ l ⟩ subst σ f ∷ Π p , q ▷ subst σ F ▹ subst (liftSubst σ) G
               / proj₁ ([ΠFG] ⊢Δ [σ])
           → Δ ⊩⟨ l ⟩ subst σ g ∷ Π p , q ▷ subst σ F ▹ subst (liftSubst σ) G
               / proj₁ ([ΠFG] ⊢Δ [σ])
           → Δ ⊩⟨ l ⟩ subst σ f ≡ subst σ g ∷ Π p , q ▷ subst σ F ▹ subst (liftSubst σ) G
               / proj₁ ([ΠFG] ⊢Δ [σ])
η-eqEqTerm {p = p} {q = q} {σ = σ} {Γ = Γ} {Δ = Δ} {f} {g} {F} {G} [Γ] [F] [G] [f0≡g0] ⊢Δ [σ]
           (Πₜ f₁ [ ⊢t , ⊢u , d ] funcF f≡f [f] [f]₁)
           (Πₜ g₁ [ ⊢t₁ , ⊢u₁ , d₁ ] funcG g≡g [g] [g]₁) =
  let [d]  = [ ⊢t , ⊢u , d ]
      [d′] = [ ⊢t₁ , ⊢u₁ , d₁ ]
      [ΠFG] = Πᵛ {F = F} {G} [Γ] [F] [G]
      [σΠFG] = proj₁ ([ΠFG] ⊢Δ [σ])
      _ , Bᵣ F′ G′ D′ ⊢F ⊢G A≡A [F]′ [G]′ G-ext = extractMaybeEmb (Π-elim [σΠFG])
      [σF] = proj₁ ([F] ⊢Δ [σ])
      [wk1F] = wk (step id) (⊢Δ ∙ ⊢F) [σF]
      var0′ = var (⊢Δ ∙ ⊢F) here
      var0 = neuTerm [wk1F] (var x0) var0′ (~-var var0′)
      var0≡0 = neuEqTerm [wk1F] (var x0) (var x0) var0′ var0′ (~-var var0′)
      [σG]′ = [G]′ (step id) (⊢Δ ∙ ⊢F) var0
      [σG] = proj₁ ([G] (⊢Δ ∙ ⊢F) (liftSubstS {F = F} [Γ] ⊢Δ [F] [σ]))
      σf0≡σg0 = escapeTermEq [σG]
                                 ([f0≡g0] (⊢Δ ∙ ⊢F)
                                          (liftSubstS {F = F} [Γ] ⊢Δ [F] [σ]))
      σf0≡σg0′ =
        PE.subst₂
          (λ x y → Δ ∙ subst σ F ⊢ x ≅ y ∷ subst (liftSubst σ) G)
          (PE.cong₂ (_∘ p ▷_) (PE.trans (subst-wk f) (PE.sym (wk-subst f))) PE.refl)
          (PE.cong₂ (_∘ p ▷_) (PE.trans (subst-wk g) (PE.sym (wk-subst g))) PE.refl)
          σf0≡σg0
      ⊢ΠFG = escape [σΠFG]
      f≡f₁′ = proj₂ (redSubst*Term {p = p} d [σΠFG] (Πₜ f₁ (idRedTerm:*: ⊢u) funcF f≡f [f] [f]₁))
      g≡g₁′ = proj₂ (redSubst*Term {p = p} d₁ [σΠFG] (Πₜ g₁ (idRedTerm:*: ⊢u₁) funcG g≡g [g] [g]₁))
      eq′  = irrelevanceEqTerm′ (cons0wkLift1-id σ G) [σG]′ [σG]
                                (app-congTerm [wk1F] [σG]′ (wk (step id) (⊢Δ ∙ ⊢F) [σΠFG])
                                              (wkEqTerm (step id) (⊢Δ ∙ ⊢F) [σΠFG] f≡f₁′) var0 var0 var0≡0)
      eq₁′ = irrelevanceEqTerm′ (cons0wkLift1-id σ G) [σG]′ [σG]
                                (app-congTerm [wk1F] [σG]′ (wk (step id) (⊢Δ ∙ ⊢F) [σΠFG])
                                              (wkEqTerm (step id) (⊢Δ ∙ ⊢F) [σΠFG] g≡g₁′) var0 var0 var0≡0)
      eq   = escapeTermEq [σG] eq′
      eq₁  = escapeTermEq [σG] eq₁′
  in Πₜ₌ f₁ g₁ [d] [d′] funcF funcG
          (≅-η-eq ⊢F ⊢u ⊢u₁ funcF funcG
                  (≅ₜ-trans (≅ₜ-sym eq) (≅ₜ-trans σf0≡σg0′ eq₁)))
          (Πₜ f₁ [d] funcF f≡f [f] [f]₁)
          (Πₜ g₁ [d′] funcG g≡g [g] [g]₁)
          (λ {_} {ρ} {Δ₁} {a} [ρ] ⊢Δ₁ [a] →
             let [F]″ = proj₁ ([F] ⊢Δ₁ (wkSubstS [Γ] ⊢Δ ⊢Δ₁ [ρ] [σ]))
                 [a]′ = irrelevanceTerm′
                          (wk-subst F) ([F]′ [ρ] ⊢Δ₁)
                          [F]″ [a]
                 fEq = PE.cong₂ (_∘ p ▷_) (PE.trans (subst-wk f) (PE.sym (wk-subst f))) PE.refl
                 gEq = PE.cong₂ (_∘ p ▷_) (PE.trans (subst-wk g) (PE.sym (wk-subst g))) PE.refl
                 GEq = PE.sym (PE.trans (subst-wk (subst (liftSubst σ) G))
                                        (PE.trans (substCompEq G)
                                                  (cons-wk-subst ρ σ a G)))
                 f≡g = irrelevanceEqTerm″ fEq gEq GEq
                         (proj₁ ([G] ⊢Δ₁ (wkSubstS [Γ] ⊢Δ ⊢Δ₁ [ρ] [σ] , [a]′)))
                        ([G]′ [ρ] ⊢Δ₁ [a])
                        ([f0≡g0] ⊢Δ₁ (wkSubstS [Γ] ⊢Δ ⊢Δ₁ [ρ] [σ] , [a]′))
                 [ρσΠFG] = wk [ρ] ⊢Δ₁ [σΠFG]
                 [f]′ : Δ ⊩⟨ _ ⟩ f₁ ∷ Π p , q ▷ F′ ▹ G′ / [σΠFG]
                 [f]′ = Πₜ f₁ (idRedTerm:*: ⊢u) funcF f≡f [f] [f]₁
                 [ρf]′ = wkTerm [ρ] ⊢Δ₁ [σΠFG] [f]′
                 [g]′ : Δ ⊩⟨ _ ⟩ g₁ ∷ Π p , q ▷ F′ ▹ G′ / [σΠFG]
                 [g]′ = Πₜ g₁ (idRedTerm:*: ⊢u₁) funcG g≡g [g] [g]₁
                 [ρg]′ = wkTerm [ρ] ⊢Δ₁ [σΠFG] [g]′
                 [f∘u] = appTerm ([F]′ [ρ] ⊢Δ₁) ([G]′ [ρ] ⊢Δ₁ [a]) [ρσΠFG] [ρf]′ [a]
                 [g∘u] = appTerm ([F]′ [ρ] ⊢Δ₁) ([G]′ [ρ] ⊢Δ₁ [a]) [ρσΠFG] [ρg]′ [a]
                 [tu≡fu] = proj₂ (redSubst*Term {p = p} (app-subst* (wkRed*Term [ρ] ⊢Δ₁ d)
                                                            (escapeTerm ([F]′ [ρ] ⊢Δ₁) [a]))
                                                ([G]′ [ρ] ⊢Δ₁ [a]) [f∘u])
                 [gu≡t′u] = proj₂ (redSubst*Term {p = p} (app-subst* (wkRed*Term [ρ] ⊢Δ₁ d₁)
                                                             (escapeTerm ([F]′ [ρ] ⊢Δ₁) [a]))
                                                 ([G]′ [ρ] ⊢Δ₁ [a]) [g∘u])
             in transEqTerm ([G]′ [ρ] ⊢Δ₁ [a]) (symEqTerm ([G]′ [ρ] ⊢Δ₁ [a]) [tu≡fu])
                             (transEqTerm ([G]′ [ρ] ⊢Δ₁ [a]) f≡g [gu≡t′u]))

-- Validity of η-equality.
η-eqᵛ : ∀ {Γ : Con Term n} {f g F G l}
        ([Γ] : ⊩ᵛ Γ)
        ([F] : Γ ⊩ᵛ⟨ l ⟩ F / [Γ])
        ([G] : Γ ∙ F ⊩ᵛ⟨ l ⟩ G / [Γ] ∙ [F])
      → let [ΠFG] = Πᵛ {Γ = Γ} {F = F} {G} [Γ] [F] [G] in
        Γ ⊩ᵛ⟨ l ⟩ f ∷ Π p , q ▷ F ▹ G / [Γ] / [ΠFG]
      → Γ ⊩ᵛ⟨ l ⟩ g ∷ Π p , q ▷ F ▹ G / [Γ] / [ΠFG]
      → Γ ∙ F ⊩ᵛ⟨ l ⟩ wk1 f ∘ p ▷ var x0 ≡ wk1 g ∘ p ▷ var x0 ∷ G
                     / [Γ] ∙ [F] / [G]
      → Γ ⊩ᵛ⟨ l ⟩ f ≡ g ∷ Π p , q ▷ F ▹ G / [Γ] / [ΠFG]
η-eqᵛ {f = f} {g} {F} {G} [Γ] [F] [G] [f] [g] [f0≡g0] {k} {Δ = Δ} {σ} ⊢Δ [σ] =
   η-eqEqTerm {f = f} {g} {F} {G} [Γ] [F] [G] [f0≡g0] ⊢Δ [σ]
                (proj₁ ([f] ⊢Δ [σ])) (proj₁ ([g] ⊢Δ [σ]))

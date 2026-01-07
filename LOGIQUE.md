Zolane – MVP (UI/UX uniquement, pas de persistance) – State avec Cubit

Portefeuille unique

Toutes les entrées et sorties alimentent un seul portefeuille (devise Euro).

Le solde total = (somme des entrées) – (somme des sorties).

Sources d’entrées

Une entrée est obligatoirement rattachée à une des 3 sources :

Immo (avec sous-choix obligatoire du bien : Bergère, Commentry, Chayet),

Salaire,

Autres.

Champs d’une entrée : source, property? (si source=Immo), montant (€), note?, date.

Types de dépenses

Deux types :

Charges immobilières (oblige à choisir le bien + la raison),

Personnelle (raison sans bien).

Charges immobilières → champs : property (Bergère/Commentry/Chayet), raison (Assurance, Electricité, Eau, Autres), montant (€), note?, date.

Personnelle → champs : raison (Ménage, Transport, Santé, Autres), montant (€), note?, date.

Tableau de bord (Accueil)

Bloc Solde global :

Titre : “Solde du portefeuille”

Montant du solde affiché en grand,

En dessous, en petit : “Entrées totales” et “Sorties totales”.

Section Biens immobiliers :

3 cards (Bergère, Commentry, Chayet) sans chiffres en aperçu.

Chaque card est un accordion : au clic, dérouler les détails du bien (liste des opérations liées à ce bien — entrées de type Immo et dépenses de type Charges immobilières).

Bouton + (FloatingActionButton) :

Au clic, afficher 2 actions : “Nouvelle entrée” et “Nouvelle dépense” (bottom sheet/formulaires).

Menu bas (Bottom Navigation) : Accueil – Immos – Portefeuille – Bilan.

Écrans secondaires

Immos : même logique que la section du tableau de bord, mais avec une vue dédiée (3 cards accordions).

Portefeuille : liste filtrable des entrées (Salaire/Autres/Immo) et dépenses personnelles.

Bilan : vue synthèse (placeholder graphique/sections, pas de data viz complexe pour le MVP UI).

Contraintes

UI/UX only (pas de DB), state via Cubit.

Devise figée en €.

Mécanique de calcul en mémoire (recalculer solde, totaux) dès ajout d’une opération.
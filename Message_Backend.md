

Salut Chabel,

On a bien avancé côté Frontend, gémini et moi, (l'application client mobile Flutter). Je te fais un point sur ce qui a été intégré et ce que le Frontend attend de l'API pour que l'intégration soit complète de bout en bout.

### 1. Intégration Paiement Kkiapay & Checkout
Côté app, on a intégré le SDK Kkiapay Flutter. Le client paie directement depuis l'app (la WebView Kkiapay gère la saisie du numéro Mobile Money et l'OTP). 
Une fois que Kkiapay renvoie un statut `SUCCESS`, l'application mobile déclenche **immédiatement** une requête pour valider la commande.

**Ce que le Frontend t'envoie :**
Requête `POST /api/v1/cart/checkout`
Payload JSON :
```json
{
  "paymentProvider": "mtn",
  "paymentPhoneNumber": "22961000000",
  "transactionId": "ID_DE_LA_TRANSACTION_KKIAPAY",
  "paymentStatus": "PAID"
}
```

**Ce que tu dois faire côté Backend :**
- Réceptionner cette requête.
- Appeler l'API de Kkiapay (via ton SDK Node.js/Python) pour **vérifier** le `transactionId`. L'app mobile n'est pas sécurisée, un utilisateur malveillant pourrait simuler cette requête. Ton backend DOIT confirmer que l'argent a bien été reçu.
- Si c'est validé, enregistrer la commande dans la base de données, vider le panier côté serveur, et renvoyer un statut `200` au Frontend.

### 2. Notifications Push (Firebase FCM)
L'application mobile est maintenant prête à recevoir des notifications Firebase (en premier plan, en arrière-plan et quand elle est tuée).

**Ce que le Frontend t'envoie :**
À chaque ouverture de session (ou quand le token change), l'app t'envoie le token FCM du téléphone.
Requête `POST /api/v1/users/fcm-token`
Payload JSON :
```json
{
  "fcmToken": "ez...TOKEN_UNIQUE_DU_TELEPHONE..."
}
```

**Ce que tu dois faire côté Backend :**
- Réceptionner cette requête et associer le `fcmToken` à l'utilisateur dans la base de données.
- Utiliser le **Firebase Admin SDK** pour envoyer les notifications PUSH à cet utilisateur lors des changements de statut (ex: "Commande acceptée", "En cours de préparation", "Prête"). 

### 3. Gestion des modes de commandes
Le panier gère désormais 3 modes de consommation qui sont envoyés à la route `/api/v1/cart/fulfillment`.
**Ce que le Frontend t'envoie :**
Requête `PATCH /api/v1/cart/fulfillment`
Payload JSON (exemple pour une commande programmée sur place) :
```json
{
  "mode": "scheduled_pickup",
  "consumptionMode": "sur_place",
  "pickupTime": "14:30"
}
```
**Ce que tu dois faire côté Backend :**
- T'assurer que ton schéma de base de données (modèle Order) supporte bien les champs `consumptionMode` (valeurs possibles: `sur_place`, `emporter`, `livraison`) et `pickupTime` (string/heure).

Est-ce que c'est bon pour toi ? Dis-moi quand ces routes sont prêtes ou si tu as besoin que j'ajuste le format du JSON envoyé par le Frontend !

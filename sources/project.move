module MyModule::GiftCard {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a gift card.
    struct GiftCard has store, key {
        balance: u64,   // The balance of tokens in the gift card
        is_redeemed: bool,  // Whether the gift card has been redeemed
    }

    /// Function to create a gift card with a specific balance.
    public fun create_gift_card(issuer: &signer, recipient: address, amount: u64) {
        // Transfer tokens to the recipient as a gift card balance
        let gift_card = GiftCard {
            balance: amount,
            is_redeemed: false,
        };
        move_to(issuer, gift_card);
    }

    /// Function to redeem a gift card.
    public fun redeem_gift_card(redeemer: &signer, recipient_address: address) acquires GiftCard {
        let gift_card = borrow_global_mut<GiftCard>(recipient_address);

        // Ensure the gift card has not already been redeemed
        assert!(!gift_card.is_redeemed, 1);

        // Redeem the gift card by transferring the balance to the redeemer
        let redemption = coin::withdraw<AptosCoin>(redeemer, gift_card.balance);
        coin::deposit<AptosCoin>(signer::address_of(redeemer), redemption);

        // Mark the gift card as redeemed
        gift_card.is_redeemed = true;
    }
}

module handson::pool {
    use aptos_framework::coin;

    struct HandsonCoin {}
    struct Pool has key {
        balance: coin::Coin<HandsonCoin>
    }

    public entry fun initialize(owner: &signer) {
        move_to(owner, Pool {
            balance: coin::zero<HandsonCoin>()
        });
    }

    #[test_only]
    use std::signer;
    #[test(owner = @handson)]
    fun test_initialize(owner: &signer) {
        initialize(owner);
        assert!(exists<Pool>(signer::address_of(owner)), 0);
    }
}
module handson::pool {
    use std::signer;
    use aptos_framework::coin;

    struct HandsonCoin {}
    struct Pool has key {
        balance: coin::Coin<HandsonCoin>
    }

    public entry fun initialize(owner: &signer) {
        assert!(!exists<Pool>(signer::address_of(owner)), 1);
        move_to(owner, Pool {
            balance: coin::zero<HandsonCoin>()
        });
    }

    #[test(owner = @handson)]
    fun test_initialize(owner: &signer) {
        initialize(owner);
        assert!(exists<Pool>(signer::address_of(owner)), 0);
    }
    #[test(owner = @handson)]
    #[expected_failure(abort_code = 1)]
    fun test_initialize_twice(owner: &signer) {
        initialize(owner);
        initialize(owner);
    }
}
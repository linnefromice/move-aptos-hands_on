module handson::pool {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::managed_coin;

    struct HandsonCoin {}
    struct Pool has key {
        balance: coin::Coin<HandsonCoin>
    }

    public entry fun initialize(owner: &signer) {
        assert!(!exists<Pool>(signer::address_of(owner)), 1);
        move_to(owner, Pool {
            balance: coin::zero<HandsonCoin>()
        });
        managed_coin::initialize<HandsonCoin>(
            owner,
            b"Handson Coin",
            b"HANDSON",
            0,
            false
        );
    }

    public entry fun register(account: &signer) {
        coin::register<HandsonCoin>(account);
    }

    public entry fun deposit(account: &signer, amount: u64) acquires Pool {
        let coin = coin::withdraw<HandsonCoin>(account, amount);
        let pool_ref = borrow_global_mut<Pool>(@handson);
        coin::merge(&mut pool_ref.balance, coin);
    }

    #[test_only]
    use aptos_framework::account;
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
    #[test(owner = @handson, account = @0x111)]
    fun test_deposit(owner: &signer, account: &signer) acquires Pool {
        let account_addr = signer::address_of(account);
        account::create_account_for_test(account_addr);

        initialize(owner);
        register(account);

        managed_coin::mint<HandsonCoin>(owner, account_addr, 100);
        deposit(account, 100);
    }
}
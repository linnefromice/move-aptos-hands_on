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

    public entry fun withdraw(account: &signer, amount: u64) acquires Pool {
        let coin = coin::extract(&mut borrow_global_mut<Pool>(@handson).balance, amount);
        coin::deposit(signer::address_of(account), coin)
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
    #[test_only]
    fun setup(owner: &signer, account: &signer) {
        account::create_account_for_test(signer::address_of(account));

        initialize(owner);
        register(account);
    }
    #[test(owner = @handson, account = @0x111)]
    fun test_deposit(owner: &signer, account: &signer) acquires Pool {
        setup(owner, account);
        let account_addr = signer::address_of(account);

        managed_coin::mint<HandsonCoin>(owner, account_addr, 100);
        deposit(account, 100);

        assert!(coin::value(&borrow_global<Pool>(signer::address_of(owner)).balance) == 100, 0);
        assert!(coin::balance<HandsonCoin>(account_addr) == 0, 0);
    }
    #[test(owner = @handson, account = @0x111)]
    fun test_withdraw(owner: &signer, account: &signer) acquires Pool {
        setup(owner, account);
        let account_addr = signer::address_of(account);

        managed_coin::mint<HandsonCoin>(owner, account_addr, 100);
        deposit(account, 100);

        withdraw(account, 75);

        assert!(coin::value(&borrow_global<Pool>(signer::address_of(owner)).balance) == 25, 0);
        assert!(coin::balance<HandsonCoin>(account_addr) == 75, 0);
    }
}
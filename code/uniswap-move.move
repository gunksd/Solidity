module UniswapV2::Pool {
    use 0x1::Coin;
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Account;
    use 0x1::Event;
    use 0x1::Math;

    struct Pool {
        coin_a_reserve: u128,
        coin_b_reserve: u128,
        total_liquidity: u128,
        fee_percent: u64,
        reentrancy_guard: bool,
        fee_pool: u128,
    }

    struct AddLiquidityEvent {
        coin_a_amount: u128,
        coin_b_amount: u128,
        liquidity_minted: u128,
        sender: address,
    }

    struct RemoveLiquidityEvent {
        coin_a_amount: u128,
        coin_b_amount: u128,
        liquidity_burned: u128,
        sender: address,
    }

    struct SwapEvent {
        input_amount: u128,
        output_amount: u128,
        input_is_coin_a: bool,
        sender: address,
    }

    public fun create_pool(account: &signer, fee_percent: u64): Pool {
        Pool {
            coin_a_reserve: 0,
            coin_b_reserve: 0,
            total_liquidity: 0,
            fee_percent,
            reentrancy_guard: false,
            fee_pool: 0,
        }
    }

    public fun add_liquidity(
        pool: &mut Pool,
        account: &signer,
        coin_a_amount: u128,
        coin_b_amount: u128
    ) -> u128 {
        assert!(coin_a_amount > 0 && coin_b_amount > 0, 1);
        assert!(!pool.reentrancy_guard, 100);
        pool.reentrancy_guard = true;

        Coin::transfer(account, @0x1, coin_a_amount);
        Coin::transfer(account, @0x1, coin_b_amount);

        let liquidity_minted = if pool.total_liquidity == 0 {
            Math::sqrt(coin_a_amount * coin_b_amount)
        } else {
            let coin_a_liquidity = (coin_a_amount * pool.total_liquidity) / pool.coin_a_reserve;
            let coin_b_liquidity = (coin_b_amount * pool.total_liquidity) / pool.coin_b_reserve;
            Math::min(coin_a_liquidity, coin_b_liquidity)
        };

        pool.coin_a_reserve = pool.coin_a_reserve + coin_a_amount;
        pool.coin_b_reserve = pool.coin_b_reserve + coin_b_amount;
        pool.total_liquidity = pool.total_liquidity + liquidity_minted;

        let sender_address = Signer::address_of(account);
        let event = AddLiquidityEvent {
            coin_a_amount,
            coin_b_amount,
            liquidity_minted,
            sender: sender_address,
        };
        Event::emit_event(&event);

        pool.reentrancy_guard = false;
        liquidity_minted
    }

    public fun remove_liquidity(
        pool: &mut Pool,
        account: &signer,
        liquidity: u128
    ) -> (u128, u128) {
        assert!(liquidity > 0 && liquidity <= pool.total_liquidity, 2);
        assert!(!pool.reentrancy_guard, 100);
        pool.reentrancy_guard = true;

        let coin_a_amount = (liquidity * pool.coin_a_reserve) / pool.total_liquidity;
        let coin_b_amount = (liquidity * pool.coin_b_reserve) / pool.total_liquidity;

        pool.coin_a_reserve = pool.coin_a_reserve - coin_a_amount;
        pool.coin_b_reserve = pool.coin_b_reserve - coin_b_amount;
        pool.total_liquidity = pool.total_liquidity - liquidity;

        Coin::transfer(account, coin_a_amount);
        Coin::transfer(account, coin_b_amount);

        let sender_address = Signer::address_of(account);
        let event = RemoveLiquidityEvent {
            coin_a_amount,
            coin_b_amount,
            liquidity_burned: liquidity,
            sender: sender_address,
        };
        Event::emit_event(&event);

        pool.reentrancy_guard = false;
        (coin_a_amount, coin_b_amount)
    }

    public fun swap(
        pool: &mut Pool,
        account: &signer,
        input_amount: u128,
        input_is_coin_a: bool
    ) -> u128 {
        assert!(input_amount > 0, 3);
        assert!(!pool.reentrancy_guard, 100);
        pool.reentrancy_guard = true;

        let fee = (input_amount * (pool.fee_percent as u128)) / 10000;
        let input_amount_after_fee = input_amount - fee;
        pool.fee_pool = pool.fee_pool + fee;
        let output_amount;

        if input_is_coin_a {
            Coin::transfer(account, @0x1, input_amount);
            let new_reserve_a = pool.coin_a_reserve + input_amount_after_fee;
            let new_reserve_b = (pool.coin_a_reserve * pool.coin_b_reserve) / new_reserve_a;
            output_amount = pool.coin_b_reserve - new_reserve_b;
            pool.coin_a_reserve = new_reserve_a;
            pool.coin_b_reserve = new_reserve_b;
        } else {
            Coin::transfer(account, @0x1, input_amount);
            let new_reserve_b = pool.coin_b_reserve + input_amount_after_fee;
            let new_reserve_a = (pool.coin_a_reserve * pool.coin_b_reserve) / new_reserve_b;
            output_amount = pool.coin_a_reserve - new_reserve_a;
            pool.coin_a_reserve = new_reserve_a;
            pool.coin_b_reserve = new_reserve_b;
        }

        Coin::transfer(account, output_amount);

        let sender_address = Signer::address_of(account);
        let event = SwapEvent {
            input_amount,
            output_amount,
            input_is_coin_a,
            sender: sender_address,
        };
        Event::emit_event(&event);

        pool.reentrancy_guard = false;
        output_amount
    }
}

address 0x1 {
    module Coin {
        public fun transfer(
            from: &signer,
            to: address,
            amount: u128
        ) {
            // Coin transfer logic here
        }
    }
}
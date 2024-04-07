#[test_only]
module suipass::suipass_test {
    use std::string::{Self};
    use std::vector;
    use std::debug::print;

    use sui::coin;
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};

    use sui::test_scenario;
    use sui::test_utils::assert_eq;

    use suipass::suipass::{Self, SuiPass};

    /* Default values */

    const OWNER: address = @0x123;

    /* Tests */

    #[test]
    fun test_flow_success() {
        let provider_admin = @0xb;
        let buyer = @0xc;

        let scenario_val = test_scenario::begin(OWNER);
        let scenario = &mut scenario_val;

        { 
            // Init contract
            suipass::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, OWNER);
        {
            // View Suipass
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Suipass object - Init"));
            print(&string::utf8(b"-----------------------------------------------"));
            print(&suipass);
            test_scenario::return_shared(suipass);
        };

        test_scenario::next_tx(scenario, OWNER);
        {
            // Create provider
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Create Provider"));
            print(&string::utf8(b"-----------------------------------------------"));
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            let suipass_cap = test_scenario::take_from_sender<suipass::AdminCap>(scenario);

            let criteria = vector::empty();
            vector::push_back(&mut criteria, b"Created at least 90 days ago.A");
            vector::push_back(&mut criteria, b"Created at least 180 days ago.#");

            suipass::add_provider(
                &suipass_cap,
                &mut suipass,
                provider_admin,
                b"Github",
                b"metadata json?",
                1_000_000, 
                500_000, 
                criteria,
                1000,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, suipass_cap);
            test_scenario::return_shared(suipass);
        };

        test_scenario::next_tx(scenario, OWNER);
        {
            // View Suipass
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Suipass object - After created a lootbox"));
            print(&string::utf8(b"-----------------------------------------------"));
            print(&suipass);
            test_scenario::return_shared(suipass);
        };

        // test_scenario::next_tx(scenario, OWNER);
        // {
        //     // Buy Lootbox
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&string::utf8(b"Purchase lootbox"));
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     let suipass = test_scenario::take_shared<suipass::Suipass>(scenario);
        //
        //     // Get lootbox info
        //     let lootbox_id = 0;
        //     let lootbox_ref = suipass::lootbox(&suipass, lootbox_id);
        //     let price = suipass::lootbox_price(lootbox_ref);
        //     let quantity_to_buy = 1;
        //
        //     print(lootbox_ref);
        //
        //     // Mint testing coin to buy
        //     let payment_coin = sui::coin::mint_for_testing<SUI>(
        //         price * quantity_to_buy, 
        //         test_scenario::ctx(scenario)
        //     );
        //
        //     suipass::purchase_lootbox(
        //         &mut suipass,
        //         suipass::lootbox_id(lootbox_ref),
        //         quantity_to_buy,
        //         buyer,
        //         &mut payment_coin,
        //         test_scenario::ctx(scenario)
        //     );
        //
        //     test_scenario::return_shared(suipass);
        //     coin::destroy_zero(payment_coin);
        // };
        //
        // let tx = test_scenario::next_tx(scenario, buyer);
        // {
        //     // View purchased lootbox
        //     let suipass = test_scenario::take_shared<suipass::Suipass>(scenario);
        //     let lootbox_id = 0;
        //     let lootbox_ref = suipass::lootbox(&suipass, lootbox_id);
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&string::utf8(b"Suipass object - After purchased a lootbox"));
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&suipass);
        //
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&string::utf8(b"Purchased Lootbox object - In buyer wallet"));
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     let purchased_lootbox = test_scenario::take_from_sender<suipass::PurchasedLootBox>(scenario);
        //     assert_eq(suipass::purchased_lootbox_id(&purchased_lootbox), suipass::lootbox_id(lootbox_ref));
        //
        //     print(&purchased_lootbox);
        //
        //     test_scenario::return_shared(suipass);
        //     test_scenario::return_to_sender(scenario, purchased_lootbox);
        // };
        //
        // let tx = test_scenario::next_tx(scenario, buyer);
        // {
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&string::utf8(b"Open Purchased Lootbox - Reward"));
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     // Use purchased lootbox
        //     let suipass = test_scenario::take_shared<suipass::Suipass>(scenario);
        //     let purchased_lootbox = test_scenario::take_from_sender<suipass::PurchasedLootBox>(scenario);
        //
        //     // Will receive some reward
        //     let reward = suipass::open_lootbox(
        //         &mut suipass,
        //         purchased_lootbox,
        //         test_scenario::ctx(scenario)
        //     );
        //
        //     print(&reward);
        //
        //     // NOTE: Just burn for testing - in pratice, this reward will be sent to the user wallet
        //     coin::burn_for_testing(reward);
        //     test_scenario::return_shared(suipass);
        // };
        //
        // let tx = test_scenario::next_tx(scenario, buyer);
        // {
        //     // View Suipass
        //     let suipass = test_scenario::take_shared<suipass::Suipass>(scenario);
        //     let lootbox_id = 0;
        //     let lootbox_ref = suipass::lootbox(&suipass, lootbox_id);
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&string::utf8(b"Suipass object - After opened a lootbox"));
        //     print(&string::utf8(b"-----------------------------------------------"));
        //     print(&suipass);
        //     // WARN: Uncomment the line below to prove that there are no PurchasedLootBox in user wallet
        //     //       (it will cause an error)
        //     // let purchased_lootbox = test_scenario::take_from_sender<suipass::PurchasedLootBox>(scenario);
        //     test_scenario::return_shared(suipass);
        // };

        test_scenario::end(scenario_val);
    }
}

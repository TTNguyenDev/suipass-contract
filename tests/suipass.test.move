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
    use suipass::provider;

    /* Default values */

    const OWNER: address = @0x123;

    /* Tests */

    #[test]
    fun test_flow_success() {
        let provider_admin = @0xb;
        let requester = @0xc;

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
            vector::push_back(&mut criteria, b"Created at least 180 days ago.#");
            vector::push_back(&mut criteria, b"Created at least 90 days ago.A");

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
            print(&string::utf8(b"Suipass object - After created provider"));
            print(&string::utf8(b"-----------------------------------------------"));
            print(&suipass);
            test_scenario::return_shared(suipass);
        };

        test_scenario::next_tx(scenario, requester);
        {
            // Submit request
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Submit Request"));
            print(&string::utf8(b"-----------------------------------------------"));
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);

            // Get Provider info
            let (provider_id, provider) = suipass::providers(&suipass, 0);
            print(provider_id);
            print(provider);

            // Mint testing coin to buy
            let payment_coin = sui::coin::mint_for_testing<SUI>(
                1_000_000, 
                test_scenario::ctx(scenario)
            );

            suipass::submit_request(
                &mut suipass,
                *provider_id,
                b"some proof",
                &mut payment_coin,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(suipass);
            coin::destroy_zero(payment_coin);
        };

        let tx = test_scenario::next_tx(scenario, requester);
        {
            // View Request
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Suipass object - After submit request"));
            print(&string::utf8(b"-----------------------------------------------"));
            print(&suipass);

            test_scenario::return_shared(suipass);
        };

        let tx = test_scenario::next_tx(scenario, provider_admin);
        {
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Approve request"));
            print(&string::utf8(b"-----------------------------------------------"));
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            let provider_cap = test_scenario::take_from_sender<provider::ProviderCap>(scenario);

            let criteria = vector::empty();
            vector::push_back(&mut criteria, 1);

            suipass::resolve_request(
                &provider_cap,
                &mut suipass,
                requester,
                b"some evidence",
                criteria,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(suipass);
            test_scenario::return_to_sender(scenario, provider_cap);
        };

        let tx = test_scenario::next_tx(scenario, requester);
        {
            // View Suipass
            let suipass = test_scenario::take_shared<suipass::SuiPass>(scenario);
            print(&string::utf8(b"-----------------------------------------------"));
            print(&string::utf8(b"Suipass object - After resolve request"));
            print(&string::utf8(b"-----------------------------------------------"));
            print(&suipass);
            test_scenario::return_shared(suipass);

            let approval = test_scenario::take_from_sender<suipass::approval::Approval>(scenario);
            print(&approval);
            test_scenario::return_to_sender(scenario, approval);

        };

        test_scenario::end(scenario_val);
    }
}

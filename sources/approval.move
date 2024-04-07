module suipass::approval {
    use std::string::{Self, String};
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};

    friend suipass::provider;

    // Errors

    //======================================================================
    // Module Structs
    //======================================================================

    struct Approval has key, store {
        id: UID,
        provider: ID,
        criteria: vector<u8>,
        evidence: String,
        issued_date: u64,
        // expiration_date: u64,
    }

    //======================================================================
    // Friend required functions
    //======================================================================

    // only suipass owner can create a provider
    public(friend) fun new(
        provider: ID,
        criteria: vector<u8>,
        evidence: vector<u8>,
        issued_date: u64,
        // expiration_date: u64,
        ctx: &mut TxContext
    ): Approval {
        Approval {
            id: object::new(ctx),
            provider,
            criteria,
            evidence: string::utf8(evidence),
            issued_date,
            // expiration_date
        }
    }

    //======================================================================
    // Accessors
    //======================================================================

    public fun id(approval: &Approval): ID {
        object::uid_to_inner(&approval.id)
    }

    public fun provider_id(approval: &Approval): ID {
        approval.provider
    }

    public fun criteria(approval: &Approval): vector<u8> {
        approval.criteria
    }
}



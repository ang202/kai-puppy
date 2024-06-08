module kai_puppy::puppy {
    use std::string::{utf8, String};
    use sui::event;
    use sui::display;
    use sui::package;

    /// An example NFT that can be minted by anybody. A Puppy is
    /// a freely-transferable object. Owner can add new traits to
    /// their puppy at any time and even change the image to the
    /// puppy's liking.
    public struct Puppy has key, store {
        id: UID,
        /// Name of the Puppy
        name: String,
    }

    /// Event: emitted when a new Puppy is minted.
    public struct PuppyMinted has copy, drop {
        /// ID of the Puppy
        puppy_id: ID,
        /// The address of the NFT minter
        minted_by: address,
    }

    public struct PuppyUpdated has copy, drop {
        /// ID of the Puppy
        puppy_id: ID,
        /// The address of the NFT minter
        minted_by: address,
    }

    public struct PUPPY has drop {}

    // ===== Init =====

    fun init(otw: PUPPY, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"description"),
            utf8(b"type"),
            utf8(b"image_url"),
        ];

        let values = vector[
            utf8(b"This dog is called {name}"),
            utf8(b"Puppy"),
            utf8(b"https://images.pexels.com/photos/1851164/pexels-photo-1851164.jpeg?auto=compress&cs=tinysrgb"),
        ];

        let publisher = package::claim(otw, ctx);

        let mut display = display::new_with_fields<Puppy>(
            &publisher, keys, values, ctx
        );

        display.update_version();

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    /// Mint a new Puppy with the given `name`, `traits` and `url`.
    /// The object is returned to sender and they're free to transfer
    /// it to themselves or anyone else.
    public entry fun mint(
        name: String,
        ctx: &mut TxContext
    ) {
        let nft = Puppy {
            id: object::new(ctx),
            name: name,
        };

        event::emit(PuppyMinted {
            puppy_id: object::id(&nft),
            minted_by: ctx.sender(),
        });

        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    public entry fun update(
        self: &mut Puppy,
        name: String,
        ctx: &TxContext
    ) {
        self.name = name;

        event::emit(PuppyUpdated {
            puppy_id: object::id(self),
            minted_by: tx_context::sender(ctx),
        });
    }

    public entry fun destroy(nft: Puppy) {
        let Puppy { 
            id, name: _,
        } = nft;

        object::delete(id)
    }
}

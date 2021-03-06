import logging
from brownie import Wei, reverts, chain

LOGGER = logging.getLogger(__name__)




def test_set_token_adr(accounts, bridge, projecttoken):
    with reverts("Ownable: caller is not the owner"):
        bridge.setConTokenAddress(projecttoken.address, {'from': accounts[2]})

    with reverts("cant set address to zero"):
        bridge.setConTokenAddress(
            '0x0000000000000000000000000000000000000000',
            {'from': accounts[0]}
        )

    bridge.setConTokenAddress(projecttoken.address, {'from': accounts[0]})
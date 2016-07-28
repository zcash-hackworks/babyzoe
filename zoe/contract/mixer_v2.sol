contract SnarkPrecompile {
    function verify_proof (bytes, bytes, bytes) returns (bool);
}



contract Mixer {
    mapping (bytes32 => bool) public serials;
    mapping (bytes32 => bool) public roots;
    SnarkPrecompile zksnark = SnarkPrecompile(0x0000000000000000000000000000000000000005);
    struct Mtree {
        uint cur;
        bytes32[16] leaves;
    }
    Mtree public MT;
    bytes public vk;


    function Mixer(bytes _vk) {
        vk = _vk;
        MT.cur = 0;
        for (uint i = 0; i < 16; i++)
            MT.leaves[i] = 0x0;
    }

    //Merkletree.append(com)
    function insert(bytes32 com) returns (bool res) {
        if (MT.cur == 16) {
            return false;
        }
        MT.leaves[MT.cur] = com;
        MT.cur++;
        return true;
    }

    function getLeaves() constant returns (bytes32[16]) {
        return MT.leaves;
    }

    function getTree() constant returns (bytes32[32] tree) {
        //bytes32[32] memory tree;
        uint i;
        for (i = 0; i < 16; i++)
            tree[16 + i] = MT.leaves[i];
        for (i = 16 - 1; i > 0; i--)
            tree[i] = sha256(tree[i*2], tree[i*2+1]);

        return tree;
    }

    //Merkletree.root()

    function getRoot() constant returns(bytes32 root) {
        root = getTree()[1];
    }

    function deposit(bytes32 com) returns (bool res) {
        if (msg.value != 1 ether) {
            msg.sender.send(msg.value);
            return false;
        }
        if (!insert(com)) {
            msg.sender.send(msg.value);
            return false;
        }
        bytes32 rt = getRoot();
        roots[rt] = true;
        return true;
    }

    function withdraw(bytes32 serial, address addr, bytes32 rt, bytes32 mac, bytes proof) returns (bool success) {
        success = false;
        bytes20 addr_byte = bytes20(addr);
        bytes memory pub = new bytes(128);
        uint i;
        for (i = 0; i < 32; i++) pub[i] = serial[i];
        for (i = 0; i < 20; i++) pub[32 + i] = addr_byte[i];
        for (i = 20; i < 32; i++) pub[32 + i] = 0;
        for (i = 0; i < 32; i++) pub[32*2 + i] = rt[i];
        for (i = 0; i < 32; i++) pub[32*3 + i] = mac[i];
        if (roots[rt] == true) {
            if (!serials[serial]) {
                if (!zksnark.verify_proof(vk, proof, pub)) {
                    return false;
                }
                serials[serial] = true;
                if (!addr.send(1 ether)) {
                    throw;
                }
                else {
                    success = true;
                }
            }
            else {
                return;
            }
        }
        else {
            return;
        }
    }
    function dummy() { }

}

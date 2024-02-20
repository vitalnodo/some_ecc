from fiat_ecc import secp256k1


def test_secp256k1_basepoint_affine_coordinates():
    b = secp256k1.BasePoint()
    x, y = b.affine_coordinates()
    assert x == 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
    assert y == 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

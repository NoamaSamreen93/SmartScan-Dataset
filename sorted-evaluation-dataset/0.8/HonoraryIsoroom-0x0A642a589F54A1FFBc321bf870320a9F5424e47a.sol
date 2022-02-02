// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HonoraryIsoroom is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => bool) internal sealedToken;
    event PermanentURI(string _value, uint256 indexed _id);

    constructor() ERC721("Honorary isoroom", "HISOROOM") {}

    function mintNFT(address recipient, string memory tokenURI)
        external
        onlyOwner
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        sealedToken[newItemId] = false;
    }

    function updateTokenURL(uint256 tokenId, string memory tokenURI)
        external
        onlyOwner
    {
        require(sealedToken[tokenId] == false, "Token already sealed.");
        _setTokenURI(tokenId, tokenURI);
    }

    function sealToken(uint256 tokenId)
        external
        onlyOwner
    {
        require(sealedToken[tokenId] == false, "Token already sealed.");
        sealedToken[tokenId] = true;
        emit PermanentURI(tokenURI(tokenId), tokenId);
    }

    function isSealed(uint256 tokenId)
        external
        view
        returns (bool)
    {
        return sealedToken[tokenId];
    }
}
//                                                                                                                                
//                                                               .'";I,^'.                                                                      
//                                                            .^:Il!ll!ll;,`.                                                                   
//                                                       ..`";llI:^'. .`";llI:^'.                                                               
//                                                    .'"Il!ll"'.         .`:l!!!:`'                                                            
//                                                 '^:l!lI:^'.               .'";ll!I,`.                                                        
//                                             .`";!Il:^'.        .'^"`.         .`,;Ill:^'.                                                    
//                                         .`,I!ll;^'.        .'^:l!!!!!l,`.         .`,IIll;^..                                                
//                                      '^,IllI:^'         .'^;!!!IIlllIl!!l,^'.        .'";l!l;"`.                                             
//                                  .`,I!!l:`'.        .'":ll!I,`'.`l!;..`^;!!lI,`.         .`,Il!l;"'.                                         
//                               '";!ll:"'.        .'^:l!ll;"'.    '!l;.    .`,;l!!l,`.         .`,Il!l:^.                                      
//                               ^l!!!l,`.      .'";l!lI,`.        '!!;.       .'^;!!ll:^'       '^;!!li;.                                      
//                               ^l!l,Illl:^''^:lll;,^'.           'l!;.           .`^:llII,`'`,;lI!::!!I.                                      
//                               ^l!l..'^:!!!!!l;"'                'l!;.               .`,;!!ll!l,`. ^l!I.                                      
//                               ^llI.    .:!l".                   'l!;.                  .';!l".    `!!I.                                      
//                               ^l!l.     ,!I`                    'l!;.                   .,!l`     `!!I.                                      
//                               ^l!l.     ,!I`                    'l!;.                    ,iI`     `l!I.                                      
//                               ^l!l.     ,!l`                    'l!;.                    ,il`     `l!I.                                      
//                               ^l!l.     ,!l`                    'l!;.                    ,il`     `l!I.                                      
//                               ^lll.     ,!l`                    'll;.                    ,il`     `l!I.                                      
//                               ^lll.     ,!l`                    'll;.                    ,il`     `l!I.                                      
//                               ^l!l.     ,!l`                 .'`:!ll"`.                  ,il`     `l!I.                                      
//                               ^l!l.     ,!l`             .'`,I!!l;:Illl;"`.              ,!l`     `l!I.                                      
//                               ^l!l.     ,!l`          '^,;l!l;"`'...'^,Il!l;,`.         .,!l`     `l!I.                                      
//                               ^l!l.     ,!I`      .'";ll!!;^'...........`";!llI,^'.     .,!!`     `l!I.                                      
//                               ^l!l.     ,!l`  .`";!!lI,^'..................'`":l!!I:`'. .,il`     `l!I.                                      
//                               ^llI.     ,!l,";!llI:^`...........................`";l!!I:";!l`     `l!I.                                      
//                               ^l!I.     ,ll!!lI,`..................................'^:l!!!ll`     ^l!I.                                      
//                               ^l!I.     ^;l!!l,`....................................'^:l!!I,'     ^l!I.                                      
//                               ^l!l.       .`,ll!l;"`............................'`,;l!!;"'.       ^!!I.                                      
//                               `Ii!^.          '"IIllI,`'.....................'^:l!Il:`.         .':iiI.                                      
//                               .`,Il!I,`'.        .`":lll;"`'.............'^,;llI,^'.        .'^:lll:"`.                                      
//                                   '";Il!I"`.         .`,Ill!;"`......'`,I!!I;"'         .'^:l!!l:`.                                          
//                                      .`,Il!l;^'.        .'^;l!!I,``":lllI,`.         .`";!ll;"'.                                             
//                                         .'`,;llI,`'.        .`":I!!lI,^'.        .'^:lll;"`.                                                 
//                                             .'^:ll!l:`.         `!l;.         '";!llI"`.                                                     
//                                                 .`,I!ll;"'.     '!l;.     .`,Ill!;"`.                                                        
//                                                     .`,Illl,`'. '!!:. .'";lll;"'.                                                            
//                                                        .'^:!llI,:llI,;IllI,`.                                                                
//                                                            .`,I!!l!!!l;"'                                                                    
//                                                                .`,:^'.                                                                       
//                                                                                                                                              
//                                                                                                                                              
//   `1/_.                                                                                                                .``.                  
//   -B$M^                                                                                                              'ri^^"  .               
//    ''.      ....         ...       ....  ..      ...            ...       ...  ....     ...                          lu     '@.              
//   ^%B%   ,x&B@B%Wj'   :j&8B@%n~'   (%%Blc%v. .,j&B@B%n!.    ^}*%B@8#(,   .%%%rj&%B8v;;j&B@%c~.        "l`+?]]{_'   `~fW~<~;~}B?~<,           
//   "$$$  :@@c:^^,~;  'n$@j!,:1$@B?  \$$@@|~; ^*$@|I,;}%@8l  }$$8[;:_#@$*` .$$$$\Il)@@@@n<I<#@@*.       :M:.    `n!    lv     '@.              
//   ^$$$  `8$$#t)+,'  \@$|     ?@$$" \$@%;   .v@$(     <$@B'`B$@^    'W@$M .$$$x    )$$n    ;$$@`       :1       ,*.   lv     '@.              
//   "$$$   'I?)fc%$@_ |@$|     ]$$$" \$@$.   .v$$|     <$$B'`B@@^    'W$$# .$$$/    [$$/    :$$$`       :?       "M.   lv     `@.              
//   "$$$  '1<:"^"r$$r 'r$@r<:;(@$%_  \$$$.    `c$@t!:I{%$&;  [@$8{;;?#$$c` .$$$/    ]$$/    :$$$`       :?       "M.   lv     '@`              
//   ^88&  ,tMB$$@W/;    ,/#@$$&ji'   )88&.      "\M@$@8j;.    `?u%$$%c{"   .888)    -%8(    ,88&`       ,+       ^c.   ;x      :f?+?'          
//             ..            .                       .             ..                                                                           
//                                                                                                                                              
//
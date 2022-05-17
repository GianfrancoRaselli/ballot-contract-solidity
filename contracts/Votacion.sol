// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Votacion {

  // direccion del propietario del contrato
  address propietario = msg.sender;
  
  // relacion entre el nombre del candidato y el hash de sus datos personales
  mapping(string => bytes32) idCandidatos;
  
  // relacion entre el nombre del candidato y el numero de votos
  mapping(string => uint) votosCandidatos;
  
  // lista para almacenar los nombres de los candidatos
  string[] candidatos;
  
  // lista de los hashes de la identidad de los votantes
  mapping(bytes32 => bool) votantes;


  // cualquier persona puede usar esta funcion para presentarse a las elecciones
  function presentarse(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public {
    // hash de los datos del candidato
    bytes32 hashCandidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));
    
    // almacenar el hash de los datos del candidato ligado a su nombre
    idCandidatos[_nombrePersona] = hashCandidato;
    
    // almacenar el nombre del candidato
    candidatos.push(_nombrePersona);
  }

  // permite visualizar las personas que se han presentado como candidatos a las votaciones
  function verCandidatos() public view returns (string[] memory) {
    // devuelve la lista de los candidatos presentados
    return candidatos;
  }

  // los votantes van a poder votar
  function votar(string memory _candidato) public {
    // hash de la direccion de la persona que ejecuta esta funcion
    bytes32 hashVotante = keccak256(abi.encodePacked(msg.sender));

    // verificamos si el votante ya ha votado
    require(!votantes[hashVotante], "Ya has votado previamente");

    // almacenamos que el votante en el mapping de votantes
    votantes[hashVotante] = true;

    // añadimos un voto al candidato seleccionado
    votosCandidatos[_candidato]++;
  }

  // dado el nombre de un candidato nos devuelve el numero de votos que tiene
  function verVotos(string memory _candidato) public view returns (uint) {
    // devolviendo el numero de votos del candidato _candidato
    return votosCandidatos[_candidato];
  }

  // funcion auxiliar que transforma un uint a un string
  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (_i != 0) {
      k = k-1;
      uint8 temp = (48 + uint8(_i - _i / 10 * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }

  // ver los votos de cada uno de los candidatos
  function verResultados() public view returns (string memory) {
    // guardamos en una variable string los candidatos con sus respectivos votos
    string memory resultados;

    // recorremos el array de candidatos para actualizar el string resultados
    for (uint i = 0; i < candidatos.length; i++) {
      // añadimos el candidato que ocupa la posicion "i" del array de candidatos y su numero de votos al string resultados
      resultados = string(abi.encodePacked(resultados, '(', candidatos[i], ' - ', uint2str(verVotos(candidatos[i])), ")  "));
    }

    // devolvemos los resultados
    return resultados;
  }

  // proporcionar el nombre del candidato ganador
  function verGanador() public view returns (string memory) {
    // la variable ganador va a contener el nombre del candidato ganador
    string memory ganador = candidatos[0];

    // la variable flag nos sirve para la situacion de empate
    bool flag;

    // recorremos el array de candidatos para determinar el candidato con un numero mayor de votos
    for (uint i = 1; i < candidatos.length; i++) {
      // comparamos si nuestro ganador ha sido superado por otro candidato
      if (votosCandidatos[ganador] < votosCandidatos[candidatos[i]]) {
        ganador = candidatos[i];
        flag = false;
      } else if (votosCandidatos[ganador] == votosCandidatos[candidatos[i]]) {
        // marcamos la variable flag en true indicando que hay un empate
        flag = true;
      }
    }

    // comprobamos si ha habido un empate entre los candidatos
    if (flag) {
      // informamos el empate
      ganador = "Hay un empate";
    }

    // devolvemos el ganador
    return ganador;
  }

}
